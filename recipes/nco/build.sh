#!/bin/bash

export HAVE_NETCDF4_H=yes
export NETCDF_ROOT=$PREFIX

if [[ $(uname) == Darwin ]]; then
export LDFLAGS="-headerpad_max_install_names"
    ./configure \
        HAVE_ANTLR=yes \
        --prefix=$PREFIX \
        --disable-regex \
        --disable-shared \
        --disable-doc
else
    ./configure \
        HAVE_ANTLR=yes \
        --prefix=$PREFIX \
        --disable-dependency-tracking \
        --enable-netcdf4 \
        --disable-static \
        --disable-udunits \
        --enable-udunits2
fi

make
make install
