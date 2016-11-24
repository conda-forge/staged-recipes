#!/bin/sh

export CC=${PREFIX}/bin/gcc
export CXXFLAGS="-fPIC $CXXFLAGS"
export LDFLAGS="-L${PREFIX}/lib $LDFLAGS"
export CPPFLAGS="-I${PREFIX}/include $CPPFLAGS"
export CFLAGS="-I${PREFIX}/include $CFLAGS"
export HAS_CAIRO=1
export F2CLIBS=gfortran
export PNG_PREFIX=${PREFIX}
export NCARG_ROOT=${PREFIX}

if [ "$(uname)" = "Darwin" ]; then
    if [ -d "/opt/X11" ]; then
        x11_lib="-L/opt/X11/lib"
        x11_inc="-I/opt/X11/include -I/opt/X11/include/freetype2"
    else
        echo "No X11 libs found. Exiting..." 1>&2
        exit
    fi
fi
     
cd src
python setup.py install
