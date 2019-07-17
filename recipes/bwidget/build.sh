#!/bin/bash

set -euo pipefail

cd src
# Remove this stuff so that lib is not polluted
rm -Rf .fslckout ChangeLog tests demo BWman
[[ ! -d $PREFIX/lib/tcl8.6/bwidget ]] || exit 1
mkdir -p $PREFIX/lib/tcl8.6/bwidget
cp -r * $PREFIX/lib/tcl8.6/bwidget/

