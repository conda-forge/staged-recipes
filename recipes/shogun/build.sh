set -e

mkdir build
cd build

cmake .. \
    -DCMAKE_PREFIX_PATH="$PREFIX" \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_META_EXAMPLES=OFF \
    -DENABLE_TESTING=OFF \
    -DENABLE_COVERAGE=OFF \
    -DUSE_SVMLIGHT=OFF \
    -DSWIG_EXECUTABLE=$PREFIX/bin/swig \
    -DLIBSHOGUN=OFF \
    -DPythonModular=ON

make install
