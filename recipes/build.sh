#!/bin/bash

if [[ $(uname) == 'Darwin' ]]; then
  OPTS="--x-includes=/usr/X11/include --x-libraries=/usr/X11/lib"
elif [[ $(uname) == 'Linux' ]]; then
  export CFLAGS="-fPIC -fopenmp $CFLAGS"
  OPTS="--with-udunits2_incdir=$PREFIX/include --with-udunits2_libdir=$PREFIX/lib --with-nc-config=$PREFIX/nc-config --with-png_incdir=$PREFIX/include --with-png_libdir=$PREFIX/lib"
fi

export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
export NETCDF_ROOT=$PREFIX

./configure --prefix=$PREFIX \
            --disable-dependency-tracking \
            $OPTS

# See https://github.com/conda-forge/cdo-feedstock/pull/8#issuecomment-257273909
# Hopefully https://github.com/conda-forge/hdf5-feedstock/pull/48 will fix this.
# eval ${LIBRARY_SEARCH_VAR}=$PREFIX/lib make check
make install
