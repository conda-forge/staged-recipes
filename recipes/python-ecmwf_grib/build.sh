#!/bin/bash

if [[ $(uname) == Darwin ]]; then
  export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
elif [[ $(uname) == Linux ]]; then
  export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi

export PYTHON="$PYTHON"
export PYTHON_LDFLAGS="$PREFIX/lib"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"

./configure --prefix=$PREFIX \
            --with-jasper=$PREFIX \
            --with-netcdf=$PREFIX \
            --with-png-support \
            --disable-fortran \
            --enable-python

make
make install

# For some reason the installer places the Python files in a sub-directory of site-packages called "grib_api". (NB. The sub-directory is not a package.)
# The install instructions in python/README include the suggestion:
# Add this folder to your PYTHONPATH and you are ready to go. Instead of that, we just rename the directory and make it a package.
mv $SP_DIR/grib_api $SP_DIR/gribapi
mv $SP_DIR/gribapi/gribapi.py $SP_DIR/gribapi/__init__.py
