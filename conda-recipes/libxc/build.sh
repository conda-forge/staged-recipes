
#if [ "$(uname)" == "Darwin" ]; then
#
#    # configure
#    ${PREFIX}/bin/cmake \
#        -H${SRC_DIR} \
#        -Bbuild \
#        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
#        -DCMAKE_BUILD_TYPE=Release \
#        -DCMAKE_C_COMPILER="${PREFIX}/bin/gcc" \
#        -DCMAKE_INSTALL_LIBDIR=lib \
#        -DBUILD_SHARED_LIBS=ON \
#        -DENABLE_OPENMP=OFF \
#        -DFRAGLIB_UNDERSCORE_L=OFF \
#        -DFRAGLIB_DEEP=OFF
#fi

if [ "$(uname)" == "Linux" ]; then

    # load Intel compilers and mkl
    source /theoryfs2/common/software/intel2016/bin/compilervars.sh intel64

    # link against older libc for generic linux
    TLIBC=/theoryfs2/ds/cdsgroup/psi4-compile/nightly/glibc2.12
    LIBC_INTERJECT="${TLIBC}/lib64/libc.so.6"

    # configure
    ${PREFIX}/bin/cmake \
        -H${SRC_DIR} \
        -Bbuild \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_COMPILER=icc \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DNAMESPACE_INSTALL_INCLUDEDIR="/libxc" \
        -DBUILD_SHARED_LIBS=ON \
        -DENABLE_XHOST=OFF \
        -DENABLE_GENERIC=ON \
        -DLIBC_INTERJECT="${LIBC_INTERJECT}" \
        -DBUILD_TESTING=ON
fi

# build
cd build
make -j${CPU_COUNT}
#make VERBOSE=1

# install
make install

# test
make test
