#!/usr/bin/env bash

# this also adds the libgpiod files but since they are
# already in the host environment, conda-build will only
# add the bin/* files to the package
make install
