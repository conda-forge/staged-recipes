
if [ "$(uname)" == "Darwin" ]; then

    # link against conda Clang
    ALLOPTS="-clang-name=${CLANG} -clangxx-name=${CLANGXX} -stdlib=libc++ -I${PREFIX}/include/c++/v1 ${OPTS}"

    # configure
    ${BUILD_PREFIX}/bin/cmake \
        -H${SRC_DIR} \
        -Bbuild \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_COMPILER=icc \
        -DCMAKE_C_FLAGS="${ALLOPTS}" \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DNAMESPACE_INSTALL_INCLUDEDIR="/libxc" \
        -DBUILD_SHARED_LIBS=ON \
        -DENABLE_XHOST=OFF \
        -DBUILD_TESTING=ON
fi
        #-DCMAKE_C_FLAGS="${ISA}" \
        #-DCMAKE_OSX_DEPLOYMENT_TARGET=''
        #-DCMAKE_C_FLAGS="-I/Users/github/toolchainconda/envs/softdev36//include/c++/v1" \

        # works
        #-DCMAKE_C_FLAGS="${CFLAGS}" \

        # works
        #-DCMAKE_C_COMPILER=${CC} \
        #-DCMAKE_C_FLAGS="${ISA}" \

if [ "$(uname)" == "Linux" ]; then

    # load Intel compilers and mkl
    source /theoryfs2/common/software/intel2018/bin/compilervars.sh intel64

    # link against conda MKL & GCC
    ALLOPTS="-gnu-prefix=${HOST}- ${OPTS}"

    # configure
    ${BUILD_PREFIX}/bin/cmake \
        -H${SRC_DIR} \
        -Bbuild \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_COMPILER=icc \
        -DCMAKE_C_FLAGS="${ALLOPTS}" \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DNAMESPACE_INSTALL_INCLUDEDIR="/libxc" \
        -DBUILD_SHARED_LIBS=ON \
        -DENABLE_XHOST=OFF \
        -DENABLE_GENERIC=OFF \
        -DBUILD_TESTING=ON
fi

# build
cd build
make -j${CPU_COUNT}

# install
make install

# test
#make test
