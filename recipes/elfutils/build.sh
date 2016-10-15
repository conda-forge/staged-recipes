#!/bin/bash
export LIBS="$(pkg-config --libs-only-l zlib) $LIBS"
export LDFLAGS="$(pkg-config --libs-only-L zlib) $LDFLAGS"
export CFLAGS="$(pkg-config --cflags zlib) $CFLAGS"
./configure --prefix=$PREFIX --with-zlib
make -j${CPU_COUNT}

# Unfortunately some tests fail, so we can't run "make check" here.
# This is probably due to this package being a very sensitive package.
# I believe this happens because it is not ready to be packaged into
# an environment such as conda where it will run in different OSes,
# environments, etc.
#
# For example, when running the tests on my personal machine, using
# the docker image provided by condaforge, 8 tests failed, while in
# CircleCI, 4 tests failed.

make install
