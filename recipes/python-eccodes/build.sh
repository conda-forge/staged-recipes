#!/usr/bin/env bash

if [[ $(uname) == Darwin ]]; then
  export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
elif [[ $(uname) == Linux ]]; then
  export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi

export PYTHON=
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"

src_dir="$(pwd)"
mkdir ../build
cd ../build
cmake $src_dir \
         -DCMAKE_INSTALL_PREFIX=$PREFIX \
         -DENABLE_JPG=1 \
         -DENABLE_NETCDF=1 \
         -DENABLE_PNG=1 \
         -DENABLE_PYTHON=1 \
         -DENABLE_FORTRAN=0

make
eval ${LIBRARY_SEARCH_VAR}=$PREFIX/lib
make install

# see https://github.com/conda-forge/python-ecmwf_grib-feedstock/blob/master/recipe/build.sh#L26
# For some reason the installer places the Python files in a sub-directory of
# site-packages called "grib_api". (NB. The sub-directory is not a package.)
# The install instructions in python/README include the suggestion:
# Add this folder to your PYTHONPATH and you are ready to go. Instead of that,
# we just rename the directory and make it a package.
mv $SP_DIR/grib_api $SP_DIR/gribapi
mv $SP_DIR/gribapi/gribapi.py $SP_DIR/gribapi/__init__.py