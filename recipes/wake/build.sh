#!/bin/bash

set -xe

# needs to have -lrt in core for bootstrap and in final link of
# bin/wake.native-cpp14-release but don't want to maintain a patch
# I'll just put it in LDFLAGS for everything.
#export LDFLAGS="$LDFLAGS -lrt"

# wake's makefile defines a VERSION macro in it's CFLAGS, we need to keep that
export CFLAGS="-DVERSION=$PKG_VERSION $CFLAGS" 

# wake's Makefile doesn't obey the environment variables but will allow
# them to be overriden on the cmdline of make so..
MAKE_ARGS=( CC="$CC" 
	    CXX="$CXX" 
	    CFLAGS="$CFLAGS" 
	    LDFLAGS="$LDFLAGS"
	    DESTDIR="$PREFIX"
	  )

# bootstrap wake
make "${MAKE_ARGS[@]}" -j $CPU_COUNT wake.db

# finish building with wake itself
export WAKE_PATH=$BUILD_PREFIX/bin 

./bin/wake --verbose build default

# don't have time to figure out why 

./bin/wake --verbose --in test_wake runTests
./bin/wake --verbose --in test_wake runUnitTests

./bin/wake install $PREFIX
