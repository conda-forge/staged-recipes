#!/bin/bash

set -x -e

INCLUDE_PATH="${PREFIX}/include"
LIBRARY_PATH="${PREFIX}/lib"

CMAKE_INSTALL_PREFIX=${PREFIX}
INCLUDE_DIRECTORIES="${PREFIX}/include"
LDFLAGS=-L"${PREFIX}/lib"

if [ "$(uname)" == "Linux" ]; then

    cd ${SRC_DIR}/escript-boost
    ./bootstrap.sh \
        --with-toolset=cc \
        --with-python-version=2.7 \
        --prefix="${PREFIX}/esys/boost" || cat bootstrap.log
    
    ./b2 \
        variant=release \
        link=shared \
        runtime-link=shared \
        threading=multi \
        toolset=cc \
        --with-python \
        --with-iostreams \
        --with-random \
        -j"${CPU_COUNT}" install || cat b2.log
        
    cd ${SRC_DIR}/escript
    scons -j"${CPU_COUNT}" \
        options_file="${SRC_DIR}/escript/scons/templates/stretch_options.py" \
        prefix="${PREFIX}" \
        cxx_extra="-fPIC" \
        boost_prefix="${PREFIX}/esys/boost" \
        boost_libs='boost_python27' \
        pythoncmd=`which python` \
        pythonlibpath="${PREFIX}/lib" \
        pythonincpath="${PREFIX}/include/python${PY_VER}" \
        pythonlibname="python2.7" \
        paso=1 \
        trilinos=0 \
        trilinos_prefix="${PREFIX}" \
        umfpack=0 \
        umfpack_prefix=["${PREFIX}/include","${PREFIX}/lib"] \
        lapack=0 \
        lapack_prefix=["${PREFIX}/include/atlas","${PREFIX}/lib"] \
        lapack_libs=['lapack'] \
        netcdf=no \
        netcdf_prefix="${PREFIX}"] \
        netcdf_libs=['netcdf_c++4','netcdf'] \
        werror=1 || cat config.log
        
fi

# "${CPU_COUNT}"
