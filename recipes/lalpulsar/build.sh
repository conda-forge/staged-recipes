#!/bin/bash
#
# Configure, build, and test a LALSuite subpackage (e.g. `lal`), including
# the SWIG interface files, but without any actual language bindings
#
# This script installs to a dummy location, which is then copied into
# the host env by install-c.sh

set -e

./configure \
	--prefix="${PREFIX}" \
	--enable-cfitsio \
	--enable-swig-iface \
	--disable-swig-octave \
	--disable-swig-python \
	--disable-python \
	--disable-gcc-flags \
	--enable-silent-rules
make -j ${CPU_COUNT}
make -j ${CPU_COUNT} check
