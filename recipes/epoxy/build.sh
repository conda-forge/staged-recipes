#! /bin/bash
# Prior to conda-forge, Copyright 2017-2019 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -ex

if [[ $target_platform == osx* ]] ; then
    meson_config_args=(
        -D docs=false
        -D x11=false
        -D tests=false
    )
else
    meson_config_args=(
        -D docs=false
        -D egl=yes
        -D x11=true
        -D tests=false
    )
fi

meson setup builddir "${meson_config_args[@]}" --prefix=$PREFIX --libdir=$PREFIX/lib
ninja -v -C builddir
ninja -C builddir install

cd $PREFIX
find . '(' -name '*.la' -o -name '*.a' ')' -delete
