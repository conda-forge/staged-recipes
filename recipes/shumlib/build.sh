#!/bin/bash

export PLATFORM=conda-forge

export SHUM_BUILD_STATIC=false
export SHUM_USE_C_OPENMP_VIA_THREAD_UTILS=false

export FPP=$CPP
export FPPFLAGS="-C -P -undef -nostdinc -DHAS_IEEE_ARITHMETIC -DEVAL_NAN_BY_BITS -DEVAL_DENORMAL_BY_BITS"

export FCFLAGS_OPENMP=-fopenmp
export FCFLAGS_PIC=-fPIC
export FCFLAGS_SHARED=-shared

export CFLAGS_OPENMP="-fopenmp -DEVAL_DENORMAL_BY_BITS"
export CFLAGS_PIC=-fPIC

export AR="${AR} -rc"

make

# Install shumlib
cp -r "build/$PLATFORM"/* "$PREFIX"

# Make sure test executables can find the libfruit.so library
export LD_LIBRARY_PATH="build/$PLATFORM/lib:$LD_LIBRARY_PATH"
make check
