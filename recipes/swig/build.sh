#!/bin/bash

# FIXME: This is a hack to make sure the environment is activated.
# The reason this is required is due to the conda-build issue
# mentioned below.
#
# https://github.com/conda/conda-build/issues/910
#
source activate "${CONDA_DEFAULT_ENV}"

./configure \
             --prefix="${PREFIX}" \
             --with-pcre-prefix="${PREFIX}" \
             --with-boost="${PREFIX}" \
             --with-tcl="${PREFIX}" \
             --with-tclconfig="${PREFIX}/lib" \
             --without-perl5 \
             --without-octave \
             --without-scilab \
             --without-java \
             --without-javascript \
             --without-gcj \
             --without-android \
             --without-guile \
             --without-mzscheme \
             --without-ruby \
             --without-php \
             --without-ocaml \
             --without-pike \
             --without-chicken \
             --without-csharp \
             --without-lua \
             --without-allegrocl \
             --without-clisp \
             --without-r \
             --without-go \
             --without-d
make
#make check
make install
