#!/bin/bash

export SAGE_SHARE="$PREFIX/share"
ln -s . src
curl -L -O https://raw.githubusercontent.com/sagemath/sage/7.5.1/build/pkgs/elliptic_curves/spkg-install
python spkg-install
