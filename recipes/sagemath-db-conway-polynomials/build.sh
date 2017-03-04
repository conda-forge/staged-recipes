#!/bin/bash

curl -L -O https://raw.githubusercontent.com/sagemath/sage/7.5.1/build/pkgs/conway_polynomials/spkg-install
ln -s . src
chmod +x spkg-install
./spkg-install
