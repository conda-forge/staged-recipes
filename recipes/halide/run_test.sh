if [[ $(uname) == "Darwin" ]]; then
    export MACOSX_DEPLOYMENT_TARGET=10.9
fi
${CXX:-c++} -std=c++11 -I $PREFIX/include $RECIPE_DIR/test.cpp $PREFIX/lib/libHalide.a -lz -o test
./test
