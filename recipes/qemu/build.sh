#!/bin/bash

set -ex

mkdir build
cd build

# bfd ld doesn't like the deprecated linker options that
# qemu 5.0.0 uses.  Link with GOLD instead
export LD="$LD_GOLD"

#host_cc defaults to hardcoded 'cc' and we're not cross-compiling
#for real so set it to the long name
../configure --prefix="$PREFIX" \
             --host-cc="$CC" \
	     --cxx="$CXX" \
             --mandir='${prefix}/man' \
             --libdir='${prefix}/lib' \
	     --with-pkgversion="$PKG_BUILD_STRING"

make -j "$CPU_COUNT" V=1
make -j "$CPU_COUNT" check
make install

