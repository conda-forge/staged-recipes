LAPACK_INTERJECT="${PREFIX}/lib/libmkl_rt.so"

cmake \
    -H${SRC_DIR} \
    -Bbuild \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DSHARED_ONLY=ON \
    -DENABLE_OPENMP=ON \
    -DENABLE_XHOST=OFF \
    -DENABLE_GENERIC=OFF \
    -DLAPACK_LIBRARIES=${LAPACK_INTERJECT} \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DENABLE_TESTS=ON

cd build
make
make install

ctest
