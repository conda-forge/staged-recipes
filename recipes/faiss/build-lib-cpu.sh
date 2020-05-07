# Build vanilla version (no avx, no gpu)
./configure --without-cuda \
  --prefix=${PREFIX} --exec-prefix=${PREFIX} \
  --with-blas=-lblas --with-lapack=-llapack

# make sets SHAREDEXT correctly for linux/osx
make install

# make builds libfaiss.a & libfaiss.so; we only want the latter
rm ${PREFIX}/lib/libfaiss.a
