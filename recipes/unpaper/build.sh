#!/bin/bash

aclocal
automake --add-missing
autoconf

./configure --prefix=$PREFIX
make -j$CPU_COUNT
## Tests are broken on osx
## see https://github.com/unpaper/unpaper/issues/77
if [[ ${target_platform} == osx-* ]]; then
    ./unpaper tests/imgsrc001.png tests/resultsA1ss.pbm
    [ -f tests/resultsA1ss.pbm ] || exit 1
else
    make check TESTS="tests/runtestA1.sh tests/runtestB1.sh tests/runtestB2.sh tests/runtestB3.sh tests/runtestC1.sh tests/runtestC2.sh tests/runtestC3.sh tests/runtestD1.sh tests/runtestD2.sh tests/runtestD3.sh"
fi
make install
