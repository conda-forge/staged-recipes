#!/bin/bash
mkdir build && cd build
../configure

# Build and install the Firefox version
make firefox-build
make firefox-install

# Build and install the Chrome version
make chrome-build
make chrome-install
