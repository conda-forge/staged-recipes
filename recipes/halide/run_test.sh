if [[ $(uname) == "Darwin" ]]; then
    # don't use clang++ from the env
    export CXX=c++
fi

${CXX:-c++} -std=c++11 -I$PREFIX/include $RECIPE_DIR/test.cpp \
    -Wl,-rpath,"$PREFIX/lib" -L$PREFIX/lib -lHalide -lz \
    -o test

./test
