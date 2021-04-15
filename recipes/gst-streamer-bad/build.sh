#!/usr/bin/env bash
set -ex

autoreconf -i
./configure --prefix="$PREFIX" \
  --enable-opengl \
  --enable-x264
make -j ${CPU_COUNT}
export XFAIL_TESTS="generic/states elements/mssdemux elements/compositor"
export XFAIL_TESTS="${XFAIL_TESTS} libs/mpegts elements/hls_demux elements/dash_mpd"
make -e check
make install
