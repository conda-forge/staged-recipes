#!/bin/bash

if [ `uname` == Darwin ]; then
    export CFLAGS="-I$PREFIX/include $CFLAGS"
    export LDFLAGS="-L$PREFIX/lib -headerpad_max_install_names $LDFLAGS"
    sed -i -e "s/@OSX_ARCH@/$ARCH/g" Lib/distutils/unixccompiler.py
fi

PYTHON_BAK=$PYTHON
unset PYTHON

if [ `uname` == Darwin ]; then
    ./configure --enable-shared --enable-ipv6 --with-ensurepip=no \
        --prefix=$PREFIX
fi
if [ `uname` == Linux ]; then
    ./configure --enable-shared --enable-ipv6 --with-ensurepip=no \
        --prefix=$PREFIX \
        --with-tcltk-includes="-I$PREFIX/include" \
        --with-tcltk-libs="-L$PREFIX/lib -ltcl8.5 -ltk8.5" \
        CPPFLAGS="-I$PREFIX/include -I$PREFIX/include/ncursesw" \
        LDFLAGS="-L$PREFIX/lib -Wl,-rpath=$PREFIX/lib,--no-as-needed"
fi

make
make install
ln -s $PREFIX/bin/python3.5 $PREFIX/bin/python
ln -s $PREFIX/bin/pydoc3.5 $PREFIX/bin/pydoc
export PYTHON=$PYTHON_BAK

if [ `uname` == Darwin ]; then
    DYNLOAD_DIR=$STDLIB_DIR/lib-dynload
    pushd Modules
    rm -rf build
    cp $RECIPE_DIR/setup_misc.py .
    $PYTHON setup_misc.py build
    mkdir -p $DYNLOAD_DIR
    cp $SRC_DIR/Modules/build/lib.macosx-*/_hashlib*.so \
       $SRC_DIR/Modules/build/lib.macosx-*/_ssl*.so \
       $SRC_DIR/Modules/build/lib.macosx-*/_sqlite3*.so \
       $SRC_DIR/Modules/build/lib.macosx-*/_tkinter*.so \
       $SRC_DIR/build/lib.macosx-*/_lzma*.so \
           $DYNLOAD_DIR
    popd
    pushd $DYNLOAD_DIR
    mv _lzma*.so _lzma.so
    popd
fi
