#!/bin/bash
if [ "$(uname)" = "Darwin" ]; then
    if [ -d "/opt/X11" ]; then
        OPTS="--x-includes=/usr/X11/include --x-libraries=/usr/X11/lib"
    else
        echo "No X11 libs found. Exiting..." 1>&2
        exit
    fi
elif [ "$(uname)" = "Linux" ]; then
    OPTS="--with-udunits2_incdir=$PREFIX/include --with-udunits2_libdir=$PREFIX/lib --with-nc-config=$PREFIX/nc-config --with-png_incdir=$PREFIX/include --with-png_libdir=$PREFIX/lib"
fi

export NETCDF_ROOT=$PREFIX

./configure --prefix=$PREFIX \
            --disable-dependency-tracking \
            $OPTS


make install
