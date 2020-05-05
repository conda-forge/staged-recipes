# Build vanilla version (no avx, no gpu)
./configure --without-cuda --prefix=${PREFIX} --exec-prefix=${PREFIX}

# translate from conda-build-var to what faiss-Makefile uses
set SHAREDEXT=${SHLIB_EXT}
make install

# make builds libfaiss.a & libfaiss.so; we only want the latter
rm ${PREFIX}/lib/libfaiss.a
