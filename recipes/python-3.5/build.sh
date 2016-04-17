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
    # Some extension modules are renamed when importing fails do to a missing
    # or incorrect shared library. These libraries are available through conda,
    # but their locations must first be corrected in the post-build step using
    # install_name_tool. Un-do this renaming so that the modules can be
    # imported after the library locations are corrected.
    pushd $PREFIX/lib/python3.5/lib-dynload
    for filename in *_failed.so; do
        [ -f "$filename" ] || continue;
        mv $filename ${filename//_failed/};
    done
    popd
fi
