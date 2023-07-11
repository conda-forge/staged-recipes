#!/bin/bash

# Install to conda style directories
[[ -d lib64 ]] && mv lib64 lib

nsightVersion=$(echo $PKG_VERSION | cut -d. -f1-3)
nsightLib32="nsight-compute/${nsightVersion}/target/linux-desktop-glibc_2_11_3-x86/"

# Remove 32bit libraries
[[ -d "${nsightLib32}" ]] && rm -rf ${nsightLib32}

mkdir -p $PREFIX/bin
cp -rv bin/ncu $PREFIX/bin
cp -rv bin/ncu-ui $PREFIX/bin
cp -rv nsight-compute/$nsightVersion $PREFIX/nsight-compute-$nsightVersion
