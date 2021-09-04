#!/bin/sh
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./build-aux

if [ "$(uname)" == "Linux" ]; then
  export LD_FLAGS="$LDFLAGS -Wl,-rpath-link,${PREFIX}/lib"
fi

./configure --prefix=$PREFIX
make -j${CPU_COUNT}
make install
