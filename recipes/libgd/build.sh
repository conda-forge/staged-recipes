#!/bin/sh

aclocal && autoconf

./configure --prefix=$PREFIX \
            --without-xpm \
            --without-x \
            --disable-werror \
            --without-webp \
|| { cat config.log; exit 1; }

make && make install
make check || failed=1
if [[ failed -eq 1 ]]; then
    grep -rl "DYLD_LIBRARY_PATH=" tests | xargs sed -i.bak "s~DYLD_LIBRARY_PATH=.*~DYLD_LIBRARY_PATH=$PREFIX/lib~g"
make check
fi
