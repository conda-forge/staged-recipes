#!/bin/bash

export BOOST_ROOT=$PREFIX
meson setup build_preproc -Dcpp_link_args='-pthread'
meson compile -C build_preproc
cp build_preproc/src/dynare-preprocessor $PREFIX/bin/dynare-preprocessor
