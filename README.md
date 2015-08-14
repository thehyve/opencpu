OpenCPU
=======

[![Build Status](https://travis-ci.org/jeroenooms/opencpu.png?branch=master)](https://travis-ci.org/jeroenooms/opencpu)

The OpenCPU framework exposes a web API interfacing R, Latex and Pandoc. This API is used for example to integrate statistical functionality into systems, share and execute scripts or reports on centralized servers, and build R based "apps". The OpenCPU server can run either as a single-user server inside the interactive R session (using httpuv), or as a cloud server that builds on Linux and rApache. The current R package forms the core of the framework. When loaded in R, it automatically initiates the single-user server and displays the web address in the console. For more information, visit the [OpenCPU website](http://www.opencpu.org).

Install Single User Server
--------------------------

Latest stable version (recommended):

    install.packages("opencpu")

Bleeding edge from Github:
  
    #update existing packages first
    library(devtools)
    install_github("jeroenooms/opencpu")

API Changes
===========

    POST .../ocpu/library/[packageName]/R/[functionName]/[sessionKey]
Will execute function within environment associates with session key, with POST body parameters.

    POST .../ocpu/library/[packageName]/R/[functionName]/new
Will execute function within new environment, containing only POST body parameters.

Ex.:
----

    POST .../ocpu/library/base/R/+/x08afe4aed7 -d "e1=a&e2=b"
Will look for *a* and *b* in *x08afe4aed7* environment.

Also possible to access *a* and *b* within the function:
    get("a", env=parent.frame())

