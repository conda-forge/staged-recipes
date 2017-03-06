if [[ $(uname) == "Darwin" ]]; then
    # don't use clang++
    export CXX=c++
fi

${CXX:-c++} -std=c++11 -I $PREFIX/include $RECIPE_DIR/test.cpp $PREFIX/lib/libHalide.a -L$PREFIX/lib -lz -o test
./test
