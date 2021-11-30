LAPACK_INTERJECT="${PREFIX}/lib/libmkl_rt.so"

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
    -DBUILD_DOXYGEN=OFF \
    -DBUILD_SPHINX=OFF \
    -DENABLE_TESTS=OFF

cd build
make -j${CPU_COUNT}
make install

cd ../PyCheMPS2
export CPATH=${CPATH}:${PREFIX}/include

${PYTHON} setup.py build_ext -L ${PREFIX}/lib
${PYTHON} setup.py install --prefix=${PREFIX}
