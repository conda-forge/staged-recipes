# configure
${BUILD_PREFIX}/bin/cmake \
    -H${SRC_DIR} \
    -Bbuild \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_CXX_COMPILER=${CXX} \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DPYTHON_EXECUTABLE="$PREFIX/bin/python" \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_DOCS=OFF \
    -DENABLE_OPENMP=OFF \
    -DENABLE_XHOST=OFF \
    -DENABLE_GENERIC=ON \
    -Dpybind11_DIR="${PREFIX}/share/cmake/pybind11" \
    -DOPENBABEL_DIR="$PREFIX" \
    -DCMAKE_PREFIX_PATH="${PREFIX}"

# build
cd build
make -j${CPU_COUNT}
cd ..

# install
cp -R pnab ${SP_DIR}
cp build/bind.*.so ${SP_DIR}/pnab
cp -R tests ${SP_DIR}/pnab
cp -R docs/latex/refman.pdf ${SP_DIR}/pnab
ls -l ${SP_DIR}/pnab
