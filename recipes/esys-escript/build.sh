#!/bin/bash

set -x -e
set -o pipefail

INCLUDE_PATH="${PREFIX}/include"
LIBRARY_PATH="${PREFIX}/lib"

# Always build PIC code for enable static linking into other shared libraries
CXXFLAGS="${CXXFLAGS} -fPIC"

if [ "$(uname)" == "Darwin" ]; then
    TOOLSET=clang
elif [ "$(uname)" == "Linux" ]; then
    TOOLSET=gcc
fi

# http://www.boost.org/build/doc/html/bbv2/tasks/crosscompile.html
cat <<EOF > ${SRC_DIR}/tools/build/src/site-config.jam
using ${TOOLSET} : custom : ${CXX} ;
EOF

LINKFLAGS="${LINKFLAGS} -L${LIBRARY_PATH}"

./bootstrap.sh \
    --prefix="${PREFIX}/esys/boost" \
    --with-toolset=cc \
    --with-icu="${PREFIX}" \
    --with-python="${PYTHON}" \
    --with-python-root="${PREFIX} : ${PREFIX}/include/python${PY_VER}m ${PREFIX}/include/python${PY_VER}" \
    2>&1 | tee bootstrap.log

sed -i.bak "s,cc,${TOOLSET},g" ${SRC_DIR}/project-config.jam

./b2 -q -d+2 \
    variant=release \
    address-model="${ARCH}" \
    architecture=x86 \
    debug-symbols=off \
    threading=multi \
    runtime-link=shared \
    link=shared \
    python=2.7 \
    toolset=${TOOLSET}-custom \
    include="${INCLUDE_PATH}" \
    cxxflags="${CXXFLAGS}" \
    linkflags="${LINKFLAGS}" \
    --layout=system \
    --with-python \
    --with-iostreams \
    --with-random \
    -j"${CPU_COUNT}" \
    install 2>&1 | tee b2.log
#  python="${PY_VER}" \

mkdir ${SRC_DIR}/trilinos_build
cd ${SRC_DIR}/trilinos_build
cmake \
    -D CMAKE_INSTALL_PREFIX="${PREFIX}/esys/trilinos" \
    -D Trilinos_ENABLE_CXX11=ON \
    -D Trilinos_ENABLE_Fortran=OFF \
    -D BUILD_SHARED_LIBS=ON \
    -D OpenMP_C_FLAGS='-w -fopenmp' \
    -D OpenMP_CXX_FLAGS='-w -fopenmp' \
    -D TPL_ENABLE_BLAS=ON \
    -D BLAS_LIBRARY_NAMES='blas' \
    -D TPL_BLAS_INCLUDE_DIRS=${PREFIX}/include/ \
    -D TPL_ENABLE_LAPACK=ON \
    -D TPL_ENABLE_Boost=ON \
    -D TPL_Boost_INCLUDE_DIRS=${PREFIX}/esys/boost/include/ \
    -D TPL_Boost_LIBRARIES=${PREFIX}/esys/boost/lib \
    -D TPL_ENABLE_Cholmod=ON \
    -D TPL_Cholmod_INCLUDE_DIRS=${PREFIX}/include/ \
    -D TPL_Cholmod_LIBRARIES='libcholmod.so;libamd.so;libcolamd.so' \
    -D TPL_ENABLE_Matio=ON \
    -D TPL_Matio_INCLUDE_DIRS=${PREFIX}/include/ \
    -D TPL_Matio_LIBRARIES=${PREFIX}/lib \
    -D TPL_ENABLE_METIS=ON \
    -D TPL_ENABLE_ParMETIS=OFF \
    -D METIS_LIBRARY_NAMES='metis' \
    -D TPL_ENABLE_ScaLAPACK=OFF \
    -D TPL_ENABLE_UMFPACK=ON \
    -D TPL_UMFPACK_INCLUDE_DIRS=${PREFIX}/include/ \
    -D Trilinos_ENABLE_Amesos2=ON \
    -D Trilinos_ENABLE_Belos=ON \
    -D Trilinos_ENABLE_Ifpack2=ON \
    -D Trilinos_ENABLE_Kokkos=ON \
    -D Trilinos_ENABLE_MueLu=ON \
    -D Trilinos_ENABLE_Tpetra=ON \
    -D Trilinos_ENABLE_Teuchos=ON \
    -D Trilinos_ENABLE_COMPLEX=ON \
    -D Trilinos_ENABLE_OpenMP=ON \
    -D Trilinos_ENABLE_MPI=OFF \
    -D Trilinos_ENABLE_ALL_OPTIONAL_PACKAGES=OFF \
    -D Trilinos_ENABLE_EXPLICIT_INSTANTIATION=ON \
${SRC_DIR}/trilinos 
make -j"${CPU_COUNT}" install

cd ${SRC_DIR}/escript
scons -j"${CPU_COUNT}" \
    options_file="${SRC_DIR}/escript/scons/templates/stretch_options.py" \
    prefix="${PREFIX}" \
    build_dir="${SRC_DIR}/escript_build" \
    cxx_extra="-fPIC" \
    boost_prefix="${PREFIX}/esys/boost" \
    boost_libs='boost_python${py}' \
    pythonlibpath="${PREFIX}/lib" \
    pythonincpath="${PREFIX}/include/python${PY_VER}" \
    pythonlibname="python${PY_VER}" \
    paso=1 \
    trilinos=1 \
    trilinos_prefix="${PREFIX}/esys/trilinos" \
    umfpack=1 \
    umfpack_prefix="${PREFIX}" \
    lapack=0 \
    lapack_prefix=["${PREFIX}/include/atlas","${PREFIX}/lib"] \
    lapack_libs=['lapack'] \
    netcdf=no \
    netcdf_prefix="${PREFIX}"] \
    netcdf_libs=['netcdf_c++4','netcdf'] \
    werror=0 \
    build_full
