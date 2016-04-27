#!/bin/bash

# See this workaround
# ( https://github.com/xianyi/OpenBLAS/issues/818#issuecomment-207365134 ).
CF="${CFLAGS}"
unset CFLAGS

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
make QUIET_MAKE=1 DYNAMIC_ARCH=1 BINARY=${ARCH} NO_LAPACK=0 NO_AFFINITY=1 USE_THREAD=1 CFLAGS="${CF}"
# Fix paths to ensure they have the $PREFIX in them.
if [[ `uname` == 'Darwin' ]]; then
    install_name_tool -change \
	    @rpath/./libgfortran.3.dylib \
	    "${PREFIX}/lib/libgfortran.3.dylib" \
	    "${PREFIX}/lib/libopenblas.dylib"
    install_name_tool -change \
	    @rpath/./libquadmath.0.dylib \
	    "${PREFIX}/lib/libquadmath.0.dylib" \
	    "${PREFIX}/lib/libopenblas.dylib"
    install_name_tool -change \
	    @rpath/./libgcc_s.1.dylib \
	    "${PREFIX}/lib/libgcc_s.1.dylib" \
	    "${PREFIX}/lib/libopenblas.dylib"
else
    eval ${LIBRARY_SEARCH_VAR}=$PREFIX/lib make test
fi
make install PREFIX=$PREFIX

# As OpenBLAS, now will have all symbols that BLAS or LAPACK have,
# create libraries with the standard names that are linked back to
# OpenBLAS. This will make it easier for packages that are looking for them.
#ln -fs $PREFIX/lib/libopenblas.a $PREFIX/lib/libblas.a
#ln -fs $PREFIX/lib/libopenblas.a $PREFIX/lib/liblapack.a
#ln -fs $PREFIX/lib/libopenblas.$DYLIB_EXT $PREFIX/lib/libblas.$DYLIB_EXT
#ln -fs $PREFIX/lib/libopenblas.$DYLIB_EXT $PREFIX/lib/liblapack.$DYLIB_EXT
