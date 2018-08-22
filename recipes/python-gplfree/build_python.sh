#!/bin/bash

# Remove bzip2's shared library if present,
# as we only want to link to it statically.
# This is important in cases where conda
# tries to update bzip2.
find "${PREFIX}/lib" -name "libbz2*${SHLIB_EXT}*" | xargs rm -fv {}

${SYS_PYTHON} ${RECIPE_DIR}/brand_python.py

# Remove test data to save space.
# Though keep `support` as some things use that.
mkdir Lib/test_keep
mv Lib/test/support Lib/test_keep/support
rm -rf Lib/test Lib/*/test
mv Lib/test_keep Lib/test

if [ $(uname) == Darwin ]; then
  # tests assume compilation with gcc, while clang is picked up
  export CC=gcc
  export CXX=g++

  export CFLAGS="-I$PREFIX/include $CFLAGS"
  export LDFLAGS="-Wl,-rpath,$PREFIX/lib -L$PREFIX/lib -headerpad_max_install_names $LDFLAGS"
  sed -i -e "s/@OSX_ARCH@/$ARCH/g" Lib/distutils/unixccompiler.py
elif [ $(uname) == Linux ]; then
  export CPPFLAGS="-I$PREFIX/include"
  export LDFLAGS="-L$PREFIX/lib -Wl,-rpath=$PREFIX/lib,--no-as-needed"
fi

./configure --enable-shared \
            --enable-ipv6 \
            --with-ensurepip=no \
            --prefix=$PREFIX \
            --with-tcltk-includes="-I$PREFIX/include" \
            --with-tcltk-libs="-L$PREFIX/lib -ltcl8.6 -ltk8.6" \
            --enable-loadable-sqlite-extensions

make -j${CPU_COUNT}
make install
ln -s $PREFIX/bin/python3.7 $PREFIX/bin/python
ln -s $PREFIX/bin/pydoc3.7 $PREFIX/bin/pydoc
