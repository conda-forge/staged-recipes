mkdir build
cd build
cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DJKQtPlotter_BUILD_EXAMPLES=OFF \
    -DJKQtPlotter_BUILD_STATIC_LIBS=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    ..
make -j${CPU_COUNT}
make install
rm $PREFIX/doc/_Readme.txt
rm $PREFIX/doc/_LICENSE.txt
rm $PREFIX/doc/_XITS_LICENSE.txt
rm $PREFIX/doc/_XITS_README.md
