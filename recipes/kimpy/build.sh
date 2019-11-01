#!/bin/bash 
export PKG_CONFIG_PATH=${PREFIX}/lib64/pkgconfig
${PYTHON} -m pip install . -vv
