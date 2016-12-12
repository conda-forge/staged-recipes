#!/bin/bash
sed -i -- "s|@prefix@|${PREFIX}|g" SDL2_mixer.pc.in
SMPEG_CONFIG="${PREFIX}/bin/smpeg2-config"
./configure --disable-sdltest --disable-dependency-tracking --prefix=${PREFIX}
make install
