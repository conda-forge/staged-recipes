@rem Need to set GOROOT explicitly.
@rem See topic "Installing to a custom location".
@rem  http://golang.org/doc/install
@set "CONDA_GOROOT_BACKUP=%GOROOT%"
@set "GOROOT=%CONDA_PREFIX%\go"