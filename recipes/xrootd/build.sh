export LDFLAGS="-L$PREFIX/lib -lncursesw -ltinfow $LDFLAGS"

# Tell setuptools not to handle dependencies
# sed -i '' 's/ install --prefix / install --single-version-externally-managed --record=record.txt --prefix/g' bindings/python/CMakeLists.txt

mkdir build
cd build

cmake \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    -DOPENSSL_ROOT_DIR="$PREFIX" \
    -DKERBEROS5_ROOT_DIR="$PREFIX" \
    -DPYTHON_EXECUTABLE=$(which python) \
    -DPYTHON_LIBRARY="$PREFIX" \
    -DBUILD_SHARED_LIBS=OFF \
    ..

make -j${NUM_CPUS}
make install
