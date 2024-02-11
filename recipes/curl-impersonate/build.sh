#!/bin/bash
mkdir build && cd build
../configure --with-libnssckbi=${PREFIX}/lib

# Build and install the Firefox version
make firefox-build
make firefox-install

# Build and install the Chrome version
make chrome-build
make chrome-install
