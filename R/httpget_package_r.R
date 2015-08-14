httpget_package_r <- function(pkgpath, requri){
  
  #load package
  reqpackage <- basename(pkgpath);
  reqlib <- dirname(pkgpath);
  
  
  
  #Package has to be loaded from reqlib, but dependencies might be loaded from global libs.
  inlib(reqlib,{
    loadPackageFrom(reqpackage, reqlib);
    
    #reqhead is function/object name
    if(req$method() == "POST"){
      reqobject <- head(requri, 1);
      #Request enviroment token
      reqenv <- requri[2]; 
      reqformat <- requri[3];
      
      if(is.na(reqenv))
        res$notfound(message=paste("Specify the enviroment: /[token] or /new"));
      
      execenv <- NULL;
      
      #Get the enviroment in which to run function
      if(reqenv != "new"){
        #Location of the tmp folder where sessions are stored
        tmpsessiondir <- file.path(gettmpdir(), "tmp_library");
        sessionpath <- file.path(tmpsessiondir, reqenv); 

        #make sure it exists
        res$checkfile(sessionpath);
        
        #enter the session path
        setwd(sessionpath);
        
        #try to use old libraries
        libfile <- file.path(sessionpath, ".Rlibs");
        if(file.exists(libfile)){
          customlib <- readRDS(libfile);
        } else {
          customlib <- NULL;
        }   
        
        #reload packages
        inlib(customlib, {
          infofile <- file.path(sessionpath, ".RInfo");
          if(file.exists(infofile)){
            loadsessioninfo(infofile);
          }   
        });
        
        #load session
        execenv <- new.env();
        sessionfile <- file.path(sessionpath, ".RData")
        if(file.exists(sessionfile)){
          load(sessionfile, envir=execenv);
        }  

      }
    }else{
      reqobject <- head(requri, 1);
      reqformat <- requri[2];  
    }
  
    
    if(!length(reqobject)){
      res$checkmethod();
      ns <- paste("package", reqpackage, sep=":")
      res$sendlist(ls(ns))
      #HTML:
      #indexdata <- data.frame(name = ls(ns), stringsAsFactors=FALSE)
      #indexdata$size <- unname(vapply(indexdata$name, function(x){object.size(get(x, ns))}, numeric(1)))
      #send_index(indexdata)
    }
    
    #Get object. Try package namespace first (won't work for lazy data)
    ns <- asNamespace(reqpackage)
    myobject <- if(exists(reqobject, ns, inherits = FALSE)){
      get(reqobject, envir = ns, inherits = FALSE)
    } else {
      #Fall back on exported env
      get(reqobject, paste("package", reqpackage, sep=":"), inherits = FALSE)
    }
    
    #only GET/POST allowed
    res$checkmethod(c("GET", "POST"));    
    
    #return object
    switch(req$method(),
      "GET" = httpget_object(myobject, reqformat, reqobject),
      "POST" = execute_function(myobject, tail(requri, -1), reqobject, execenv),
      stop("invalid method")
    );
  });
}
