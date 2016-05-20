#!/bin/bash

cat > site.cfg <<EOF
[DEFAULT]
library_dirs = $PREFIX/lib
include_dirs = $PREFIX/include

[atlas]
atlas_libs = openblas
libraries = openblas

[openblas]
libraries = openblas
library_dirs = $PREFIX/lib
include_dirs = $PREFIX/include

EOF


$PYTHON setup.py config
$PYTHON setup.py build
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
