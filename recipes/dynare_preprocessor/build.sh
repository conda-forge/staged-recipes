#!/bin/bash

export BOOST_ROOT=$PREFIX
meson setup --buildtype=release build_preproc -Dcpp_link_args='-pthread'
meson compile -C build_preproc
mkdir -p $PREFIX/bin
cp build_preproc/src/dynare-preprocessor $PREFIX/bin/dynare-preprocessor
