#! /bin/bash

# Strip any pre-set C++ standard, configure will add the appropriate one
export CXXFLAGS=$(echo "$CXXFLAGS" | perl -pe 's/-std=\S+\s/ /')
echo "build.sh updated CXXFLAGS=${CXXFLAGS}"

# Build for these backend data formats
echo "asp fits guppi lwa sigproc vdif" > backends.list

./configure --prefix=${PREFIX} --disable-local --enable-shared \
	  --includedir=${PREFIX}/include/dspsr \
	    PGPLOT_DIR=${PREFIX}/include/pgplot
make -j${CPU_COUNT}
make install
