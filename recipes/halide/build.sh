if [[ $(uname) == "Darwin" ]]; then
    # don't use clang++ from the env
    export CXX=c++
else
    # need to look in $PREFIX for zlib
    export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
fi

make -j${NUM_CPUS}
make install PREFIX=$PREFIX

if [[ $(uname) == "Darwin" ]]; then
    # set the dll id on macOS
    LIBHALIDE="$PREFIX/lib/libHalide.so"
    install_name_tool -id $LIBHALIDE $LIBHALIDE
fi
