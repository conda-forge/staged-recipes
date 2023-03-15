#!/usr/bin/env bash

set -ex

#
## If building with ENABLE_PYTHON=ON, relocate python scripts to expected location:
## (Avoiding setup.py which runs cmake again, separately)
##mkdir -p ${SP_DIR}
##mv ${PREFIX}/lib/pylibxc ${SP_DIR}/
#
#if [[ -z "${cuda_compiler_version+x}" || "${cuda_compiler_version}" == "None" ]]; then
#if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
#    ctest --repeat until-pass:5
#fi
#fi
########

    #if [ "$(uname)" == "Darwin" ]; then
    # for FortranCInterface
    #CMAKE_Fortran_FLAGS="${KEEPFFLAGS} -L${CONDA_BUILD_SYSROOT}/usr/lib/system/ ${OPTS}"

${BUILD_PREFIX}/bin/cmake ${CMAKE_ARGS} \
    -S${SRC_DIR} \
    -Bbuild \
    -G"Ninja" \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_CXX_COMPILER=${CXX} \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_Fortran_COMPILER=${FC} \
    -DCMAKE_Fortran_FLAGS="${FFLAGS}" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DPYMOD_INSTALL_LIBDIR="/python${PY_VER}/site-packages" \
    -DPYTHON_INTERPRETER=${PYTHON} \
    -DENABLE_OPENMP=OFF \
    -DENABLE_GENERIC=OFF \
    -DENABLE_DOCS=OFF \
    -DENABLE_TESTS=ON \
    -DENABLE_TIMER=OFF \
    -DENABLE_LOGGER=OFF \
    -DBUILD_STANDALONE=ON \
    -DENABLE_CXX11_SUPPORT=ON

cmake --build build --target install -j${CPU_COUNT}

rm ${PREFIX}/share/cmake/PCMSolver/PCMSolverTargets-static-release.cmake
rm ${PREFIX}/share/cmake/PCMSolver/PCMSolverTargets-static.cmake
rm ${PREFIX}/lib/libpcm.a

## test
## green_spherical_diffuse hitting an Intel 2018+Eigen bug
## but they can be run if static lib is built
## from-file fails b/c of my naming temp file hacks of v1.2.1.1
cd build
if [ "$(uname)" == "Darwin" ]; then
#    install_name_tool -add_rpath ${PREFIX}/lib/ lib/libpcm.1.dylib
#    install_name_tool -add_rpath ${PREFIX}/lib/ bin/unit_tests
#    install_name_tool -add_rpath ${PREFIX}/lib/ bin/Fortran_host
    ctest -E "from-file" -j${CPU_COUNT}
fi
if [ "$(uname)" == "Linux" ]; then
    ctest -E "from-file" --rerun-failed --output-on-failure -j${CPU_COUNT}
    # ctest -E "(from-file|green_spherical_diffuse)" -j${CPU_COUNT}
fi

# Notes
# -----

# * [Feb 2022] "libz.so: undefined reference to `memcpy@GLIBC_2.14'" observed and not
#   fixable by moving back gcc to 7.3 from 7.5 or changing unset flags. So dropping
#   Intel and using straight conda compilers.
# * [Apr 2018] Removing -DSHARED_LIBRARY_ONLY=ON so that can build
#   and run tests. We don't want to distribute static libs in a conda
#   pkg though, and unless user sets static/shared component, can't trust
#   `find_package(PCMSolver)` to return shared. So removing all the static
#   lib stuff immediately after install.

#     force Intel compilers to find 5.2 gcc headers
#    export GXX_INCLUDE="${PREFIX}/gcc/include/c++"
#    export GXX_INCLUDE="${BUILD_PREFIX}/${HOST}/include/c++/7.2.0/bits/stl_vector.h"

#if [ "$(uname)" == "Linux" ]; then
#
#      LD_LIBRARY_PATH=${PREFIX}/lib:$LD_LIBRARY_PATH \
#           PYTHONPATH=${PREFIX}/bin:${PREFIX}/lib/${PYMOD_INSTALL_LIBDIR}:$PYTHONPATH \
#                 PATH=${PREFIX}/bin:$PATH \
#        ctest -j${CPU_COUNT}
#fi
