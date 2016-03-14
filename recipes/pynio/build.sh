#!/bin/sh

export LDFLAGS="-L${PREFIX}/lib"

if [[ $(uname) == Darwin ]]; then
export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
fi

export F2CLIBS=gfortran
export NETCDF_PREFIX=${PREFIX}
export HAS_NETCDF4=1
export HAS_GDAL=1
export HAS_HDF4=1
export HAS_HDF5=1
export HAS_GDAL=1
export HAS_SZIP=0
export HAS_GRIB2=1
export HAS_HDFEOS=1
export HAS_HDFEOS5=1

export CXXFLAGS="-fPIC"
export CPPFLAGS="-I${PREFIX}/include"
export CFLAGS="-I${PREFIX}/include"

$PYTHON setup.py install
