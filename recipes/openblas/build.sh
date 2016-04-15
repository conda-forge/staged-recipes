# Depending on our platform, shared libraries end with either .so or .dylib
if [[ `uname` == 'Darwin' ]]; then
     export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
#    DYLIB_EXT=dylib
else
     export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
#    DYLIB_EXT=so
fi

# Build all CPU targets and allow dynamic configuration
# Build LAPACK.
# Enable threading. This can be controlled to a certain number by
# setting OPENBLAS_NUM_THREADS before loading the library.
make QUIET_MAKE=1 DYNAMIC_ARCH=1 BINARY=${ARCH} NO_LAPACK=0 NO_AFFINITY=1 USE_THREAD=1 CFLAGS="-Wno-everything"
eval ${LIBRARY_SEARCH_VAR}=$PREFIX/lib make test
make install PREFIX=$PREFIX

# As OpenBLAS, now will have all symbols that BLAS or LAPACK have,
# create libraries with the standard names that are linked back to
# OpenBLAS. This will make it easier for packages that are looking for them.
#ln -fs $PREFIX/lib/libopenblas.a $PREFIX/lib/libblas.a
#ln -fs $PREFIX/lib/libopenblas.a $PREFIX/lib/liblapack.a
#ln -fs $PREFIX/lib/libopenblas.$DYLIB_EXT $PREFIX/lib/libblas.$DYLIB_EXT
#ln -fs $PREFIX/lib/libopenblas.$DYLIB_EXT $PREFIX/lib/liblapack.$DYLIB_EXT
