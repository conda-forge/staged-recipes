if [ "$(uname)" == "Darwin" ]; then
    ARCH_ARGS=""

    # c-f-provided CMAKE_ARGS handles CMAKE_OSX_DEPLOYMENT_TARGET, CMAKE_OSX_SYSROOT
fi
if [ "$(uname)" == "Linux" ]; then
    ARCH_ARGS=""

    # c-f/staged-recipes on Linux is inside a non-psi4 git repo, messing up psi4's version computation.
    #   The "staged-recipes" skip pattern now in psi4 may need readjusting for feedstock. Diagnostics below.
    git rev-parse --is-inside-work-tree
    git rev-parse --show-toplevel
fi

echo '__version_long = '"'$PSI4_PRETEND_VERSIONLONG'" > psi4/metadata.py

# Note: bizarrely, Linux (but not Mac) using `-G Ninja` hangs on [205/1223] at
#   c-f/staged-recipes Azure CI --- thus the fallback to GNU Make.

${BUILD_PREFIX}/bin/cmake ${CMAKE_ARGS} ${ARCH_ARGS} \
  -S ${SRC_DIR} \
  -B build \
  -D CMAKE_INSTALL_PREFIX=${PREFIX} \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_C_COMPILER=${CC} \
  -D CMAKE_CXX_COMPILER=${CXX} \
  -D CMAKE_C_FLAGS="${CFLAGS}" \
  -D CMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -D CMAKE_Fortran_COMPILER=${FC} \
  -D CMAKE_Fortran_FLAGS="${FFLAGS}" \
  -D CMAKE_INSTALL_LIBDIR=lib \
  -D PYMOD_INSTALL_LIBDIR="/python${PY_VER}/site-packages" \
  -D Python_EXECUTABLE=${PYTHON} \
  -D CMAKE_INSIST_FIND_PACKAGE_gau2grid=ON \
  -D MAX_AM_ERI=5 \
  -D CMAKE_INSIST_FIND_PACKAGE_Libint2=ON \
  -D CMAKE_INSIST_FIND_PACKAGE_pybind11=ON \
  -D CMAKE_INSIST_FIND_PACKAGE_Libxc=ON \
  -D CMAKE_INSIST_FIND_PACKAGE_qcelemental=ON \
  -D CMAKE_INSIST_FIND_PACKAGE_qcengine=ON \
  -D psi4_SKIP_ENABLE_Fortran=ON \
  -D ENABLE_dkh=ON \
  -D CMAKE_INSIST_FIND_PACKAGE_dkh=ON \
  -D ENABLE_OPENMP=ON \
  -D ENABLE_XHOST=OFF \
  -D ENABLE_GENERIC=OFF \
  -D LAPACK_LIBRARIES="${PREFIX}/lib/libmkl_rt${SHLIB_EXT}" \
  -D CMAKE_VERBOSE_MAKEFILE=OFF \
  -D CMAKE_PREFIX_PATH="${PREFIX}"

# addons when ready for c-f
#  -D ENABLE_ambit=ON \
#  -D CMAKE_INSIST_FIND_PACKAGE_ambit=ON \
#  -D ENABLE_CheMPS2=ON \
#  -D CMAKE_INSIST_FIND_PACKAGE_CheMPS2=ON \
#  -D ENABLE_ecpint=ON \
#  -D CMAKE_INSIST_FIND_PACKAGE_ecpint=ON \
#  -D ENABLE_gdma=ON \
#  -D CMAKE_INSIST_FIND_PACKAGE_gdma=ON \
#  -D ENABLE_PCMSolver=ON \
#  -D CMAKE_INSIST_FIND_PACKAGE_PCMSolver=ON \
#  -D ENABLE_simint=ON \
#  -D SIMINT_VECTOR=sse \
#  -D CMAKE_INSIST_FIND_PACKAGE_simint=ON \

cmake --build build --target install -j${CPU_COUNT}

# pytest in conda testing stage
