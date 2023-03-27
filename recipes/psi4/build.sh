if [ "$(uname)" == "Darwin" ]; then
    ARCH_ARGS=""
fi
if [ "$(uname)" == "Linux" ]; then
    ARCH_ARGS=""

    # c-f/staged-recipes on Linux is inside a non-psi4 git repo, messing up psi4's version computation.
    #   The "staged-recipes" skip pattern now in psi4 may need readjusting for feedstock. Diagnostics below.
    git rev-parse --is-inside-work-tree
    git rev-parse --show-toplevel
fi

echo ${CMAKE_ARGS}

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
  -D psi4_SKIP_ENABLE_Fortran=ON ^
  -D ENABLE_dkh=ON \
  -D CMAKE_INSIST_FIND_PACKAGE_dkh=ON \
  -D ENABLE_OPENMP=ON \
  -D ENABLE_XHOST=OFF \
  -D ENABLE_GENERIC=OFF \
  -D LAPACK_LIBRARIES="${PREFIX}/lib/libmkl_rt${SHLIB_EXT}" \
  -D CMAKE_VERBOSE_MAKEFILE=OFF \
  -D CMAKE_PREFIX_PATH="${PREFIX}"

# addons when ready for c-f
#  -DENABLE_ambit=ON \
#  -DCMAKE_INSIST_FIND_PACKAGE_ambit=ON \
#  -DENABLE_CheMPS2=ON \
#  -DCMAKE_INSIST_FIND_PACKAGE_CheMPS2=ON \
#  -DENABLE_ecpint=ON \
#  -DCMAKE_INSIST_FIND_PACKAGE_ecpint=ON \
#  -DENABLE_gdma=ON \
#  -DCMAKE_INSIST_FIND_PACKAGE_gdma=ON \
#  -DENABLE_PCMSolver=ON \
#  -DCMAKE_INSIST_FIND_PACKAGE_PCMSolver=ON \
#  -DENABLE_simint=ON \
#  -DSIMINT_VECTOR=sse \
#  -DCMAKE_INSIST_FIND_PACKAGE_simint=ON \

# mac?
#  -DOpenMP_C_FLAG="-fopenmp=libiomp5" \
#  -DOpenMP_CXX_FLAG="-fopenmp=libiomp5" \
#  -DCMAKE_OSX_DEPLOYMENT_TARGET=''

cmake --build build --target install -j${CPU_COUNT}

# pytest in conda testing stage

#############

# * check psi4 consumption works
# * check psi4 --version matches {{ version }}


#if [ "$(uname)" == "Darwin" ]; then
#
#    ## Intel compilers
#    ## * link against conda Clang for icpc
#    #ALLOPTS="-clang-name=${CLANG} -msse4.1 -axCORE-AVX2"
#    #ALLOPTSCXX="-clang-name=${CLANG} -clangxx-name=${CLANGXX} -stdlib=libc++ -I${PREFIX}/include/c++/v1 -msse4.1 -axCORE-AVX2 -mmacosx-version-min=10.9"

## for omp detection
##rm -rf objdir-clang/ && cmake -H. -Bobjdir-clang -DCMAKE_CXX_COMPILER=${CLANGXX} -DCMAKE_C_COMPILER=${CLANG} -DOpenMP_CXX_FLAG="-fopenmp=libiomp5" -DPYTHON_EXECUTABLE=/Users/github/toolchainconda/envs/tools/bin/python -DLAPACK_LIBRARIES="/Users/github/toolchainconda/envs/tools/lib/libmkl_rt.dylib;/Users/github/toolchainconda/envs/tools/lib/libiomp5.dylib" -DLAPACK_INCLUDE_DIRS=/Users/github/toolchainconda/envs/tools//include/
##need llvm-openmp and intel-openmp
#
#    # remove conda-build-bound Cache file, to be replaced by psi4-dev
#    rm ${PREFIX}/share/cmake/psi4/psi4PluginCache.cmake
#
#    # generalize Targets.cmake files
#    sed -i '' "s|/usr/lib/libpthread.dylib|-lpthread|g" ${PREFIX}/share/cmake/TargetHDF5/TargetHDF5Targets.cmake
#    sed -i '' "s|/usr/lib/libdl.dylib|-ldl|g" ${PREFIX}/share/cmake/TargetHDF5/TargetHDF5Targets.cmake
#    sed -i '' "s|/usr/lib/libm.dylib|-lm|g" ${PREFIX}/share/cmake/TargetHDF5/TargetHDF5Targets.cmake
#fi
#
#if [ "$(uname)" == "Linux" ]; then
#
#    LAPACK_INTERJECT="${PREFIX}/lib/libmkl_rt${SHLIB_EXT};-Wl,-Bstatic;-lsvml;-Wl,-Bdynamic"
#
#    # remove conda-build-bound Cache file, to be replaced by psi4-dev
#    rm ${PREFIX}/share/cmake/psi4/psi4PluginCache.cmake
#
#    # generalize Targets.cmake files
#    sed -i "s|${BUILD_PREFIX}/${HOST}/sysroot/usr/lib/librt.so|-lrt|g" ${PREFIX}/share/cmake/TargetHDF5/TargetHDF5Targets.cmake
#    sed -i "s|${BUILD_PREFIX}/${HOST}/sysroot/usr/lib/libpthread.so|-lpthread|g" ${PREFIX}/share/cmake/TargetHDF5/TargetHDF5Targets.cmake
#    sed -i "s|${BUILD_PREFIX}/${HOST}/sysroot/usr/lib/libdl.so|-ldl|g" ${PREFIX}/share/cmake/TargetHDF5/TargetHDF5Targets.cmake
#    sed -i "s|${BUILD_PREFIX}/${HOST}/sysroot/usr/lib/libm.so|-lm|g" ${PREFIX}/share/cmake/TargetHDF5/TargetHDF5Targets.cmake
#    sed -i "s|;-Wl,-Bstatic;-lsvml;-Wl,-Bdynamic||g" ${PREFIX}/share/cmake/TargetLAPACK/TargetLAPACKTargets.cmake
#fi

# NOTES
# -----

# * old full ctests
#    # test
#    # * full PREFIX is too long for shebang (in bin/psi4 tests), so use env python just for tests
#    # * this doesn't work for DDD, so comment psi4_reserve, inclusive
#    mv stage/bin/psi4 stage/bin/psi4_reserve
#    echo "#! /usr/bin/env python" > stage/bin/psi4
#    cat stage/bin/psi4_reserve >> stage/bin/psi4
#    chmod u+x stage/bin/psi4
#    stage/bin/psi4 ../tests/tu1-h2o-energy/input.dat
#    MKL_CBWR=AVX ctest -j${CPU_COUNT}  --test-timeout 3600 #-L quick
#    mv -f stage/bin/psi4_reserve stage/bin/psi4

# * old dashboard upload
#   MKL_CBWR=AVX ctest -M Nightly -T Test -T Submit -j${CPU_COUNT} #-L quick
#        -DBUILDNAME="LAB-RHEL7-gcc7.3-intel18.0.3-mkl-py${CONDA_PY}-release-conda" \
#        -DSITE="gatech-conda" \
#        -DBUILDNAME="LAB-OSX-clang4.0.1-omp-mkl-py${CONDA_PY}-release-conda" \
#        -DSITE=gatech-mac-conda \
# * source /theoryfs2/common/software/intel2019/bin/compilervars.sh intel64

# * seems to slow down tests  #export PSI_SCRATCH=/scratch/psilocaluser/

# RIP c-side EFP
#        -DENABLE_libefp=ON \
#        -DCMAKE_INSIST_FIND_PACKAGE_libefp=ON \
#        -DCMAKE_INSIST_FIND_PACKAGE_pylibefp=ON \

    #sed -i "s|/opt/anaconda1anaconda2anaconda3|${PREFIX}|g" ${PREFIX}/share/psi4/python/pcm_placeholder.py
    #LD_LIBRARY_PATH=${PREFIX}/lib:$LD_LIBRARY_PATH \
    #     PYTHONPATH=${PREFIX}/bin:${PREFIX}/lib${PYMOD_INSTALL_LIBDIR}:$PYTHONPATH \
    #           PATH=${PREFIX}/bin:$PATH \

    # * HOST=x86_64-conda_cos6-linux-gnu
    #OPTS="-gnu-prefix=x86_64-conda_cos6-linux-gnu- -msse2 -axCORE-AVX2,AVX"

    #sed -i.bak "s|/opt/anaconda1anaconda2anaconda3|${PREFIX}|g" ${PREFIX}/share/psi4/python/pcm_placeholder.py
    #DYLD_LIBRARY_PATH=${PREFIX}/lib:$DYLD_LIBRARY_PATH \
    #       PYTHONPATH=${PREFIX}/bin:${PREFIX}/lib/python2.7/site-packages:$PYTHONPATH \
    #             PATH=${PREFIX}/bin:$PATH \

