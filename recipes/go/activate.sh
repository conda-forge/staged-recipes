#!/bin/bash

# Need to set GOROOT explicitly.
# See topic "Installing to a custom location".
# ( http://golang.org/doc/install )
export CONDA_GOROOT_BACKUP="${GOROOT}"
export GOROOT="${CONDA_PREFIX}/go"
