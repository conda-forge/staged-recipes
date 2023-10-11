#!/bin/bash

export BOOST_ROOT=$CONDA_PREFIX
# echo $BOOST_ROOT
meson setup build_preproc -Dcpp_link_args='-pthread -static'
meson compile -C build_preproc
mkdir $PREFIX/bin
cp build_preproc/src/dynare-preprocessor $PREFIX/bin/dynare_preprocessor

