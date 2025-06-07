#!/bin/bash

export BOOST_ROOT=$PREFIX

cp $RECIPE_DIR/meson.build src/meson.build

meson setup --prefix=$PREFIX --bindir=$PREFIX/bin --libdir=$PREFIX/lib --includedir=$PREFIX/include \
    --buildtype=release build_preproc \
    -Dcpp_args="-w  -Wno-enum-constexpr-conversion -I${PREFIX}/include/pybind11"  \
    -Dcpp_link_args="-w  -Wno-enum-constexpr-conversion -I${PREFIX}/include/pybind11" \

meson compile -C build_preproc
meson install -C build_preproc #--destdir="../

rm $PREFIX/bin/python
