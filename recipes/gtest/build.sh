#!/bin/bash
cmake $SRC_DIR/CMakeLists.txt
make
cp libgtest.a $PREFIX/lib/
cp libgtest_main.a $PREFIX/lib/
cp -r $SRC_DIR/include/gtest $PREFIX/include/
