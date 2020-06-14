cp $RECIPE_DIR/CMakeLists.txt .

mkdir cmake_build
cd cmake_build

cmake -LAH                            \
    -DCMAKE_BUILD_TYPE=Release        \
    -DCMAKE_INSTALL_PREFIX=$PREFIX    \
    -DCMAKE_INSTALL_LIBDIR=lib        \
    ..

make
make install
