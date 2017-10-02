@rem Need to set GOROOT explicitly.
@rem See topic "Installing to a custom location".
@rem  http://golang.org/doc/install
@set "CONDA_GOOROOT_BACKUP=%GOROOT%"
@set "GOROOT=%CONDA_DEFAULT_ENV%\go"
