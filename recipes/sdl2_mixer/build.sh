#!/bin/bash

# Make sure TravisCI can find SDL2
if [ `uname` == Darwin ]; then
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,$PREFIX/lib"
fi

sed -i -- "s|@prefix@|${PREFIX}|g" SDL2_mixer.pc.in
SMPEG_CONFIG="${PREFIX}/bin/smpeg2-config"
./configure --disable-dependency-tracking --prefix=${PREFIX}
make install
