@echo off
set "CONDA_BACKUP_GOROOT=%GOROOT%"
set "GOROOT=%CONDA_PREFIX%\go"

set "CONDA_BACKUP_CGO_ENABLED=%CGO_ENABLED%"
set "CGO_ENABLED=0"
