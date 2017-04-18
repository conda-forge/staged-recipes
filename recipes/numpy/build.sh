#!/bin/bash

cat > site.cfg <<'siteconfig'
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
siteconfig

$PYTHON setup.py config
$PYTHON setup.py build -j $CPU_COUNT --fcompiler=gfortran
$PYTHON setup.py install --old-and-unmanageable
