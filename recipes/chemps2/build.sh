# set -x

LAPACK_INTERJECT="${PREFIX}/lib/libmkl_rt.so"
# link against conda MKL & GCC
# if [ "$blas_impl" = "mkl" ]; then
#     LAPACK_INTERJECT="${PREFIX}/lib/libmkl_rt.so"
# else
#     LAPACK_INTERJECT="${PREFIX}/lib/libopenblas.so"
# fi
# ALLOPTS="-gnu-prefix=${HOST}- ${OPTS}"

# configure
cmake \
    -H${SRC_DIR} \
    -Bbuild \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DSHARED_ONLY=ON \
    -DENABLE_OPENMP=ON \
    -DENABLE_XHOST=OFF \
    -DENABLE_GENERIC=OFF \
    -DMKL=ON \
    -DLAPACK_LIBRARIES=${LAPACK_INTERJECT} \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DENABLE_TESTS=OFF
    # -DCMAKE_BUILD_TYPE=Release \
    # -DCMAKE_C_COMPILER=icc \
    # -DCMAKE_CXX_COMPILER=icpc \
    # -DCMAKE_C_FLAGS="${ALLOPTS}" \
    # -DCMAKE_CXX_FLAGS="${ALLOPTS}" \
    # -DBUILD_DOXYGEN=OFF \
    # -DBUILD_SPHINX=OFF \

# build
cd build
make -j${CPU_COUNT}

# install
make install

# test
# outside build phase

################################################################################

# configure
cd ../PyCheMPS2
export CPATH=${CPATH}:${PREFIX}/include

# build
${PYTHON} setup.py build_ext -L ${PREFIX}/lib

# install
${PYTHON} setup.py install --prefix=${PREFIX}

# test
# outside build phase

# NOTES:
#   '-Wl,-Bstatic;ifport;ifcore;imf;svml;     m;ipgo;                       irc;pthread;svml;c;irc_s;dl;c'
#                              'imf;svml;irng;m;ipgo;decimal;cilkrts;stdc++;irc;        svml;c;irc_s;dl;c')

#    * prevent lgomp being linked and allow liomp5 on Mac gnu
#    if [ "${PSI_BUILD_CCFAM}" == "gnu" ]; then
#        sed -i '' "s|-fopenmp||g" ${SRC_DIR}/build/CheMPS2/CMakeFiles/chemps2-shared.dir/link.txt
#        sed -i '' "s|-fopenmp||g" ${SRC_DIR}/build/CheMPS2/CMakeFiles/chemps2-bin.dir/link.txt
#    fi

# * -DHDF5_VERSION="${hdf5}"

# * for gcc82 before CheMPS2#66  -DLIBC_INTERJECT="-lhdf5;-lmkl_rt" \

