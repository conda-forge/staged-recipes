#!/bin/bash
cmake -G"Unix Makefiles" \
      -DCMAKE_BUILD_TYPE=Release \
      -DUSE_PNG=1 \
      -DPARSE_GCC_ERRORS=0 \
      -DUSE_OPENMP=0 \
      -DDYNAMIC_LINKING=1 \
      -DUSE_PROFILING=0 \
      -DUSE_SSE=1 \
      -DUSE_BLAS=1 \
      -DUSE_LAPACK=1 \
      -DUSE_DOXYGEN=0 \
      -DUSE_QT=0 \
      -DUSE_CUDA=0 \
      -DUSE_OPENMESH=0 \
      -DUSE_VTK=0 \
      -DUSE_SUITESPARSE=0 \
      -DUSE_FOX=0 \
      -DBUILD_FOX=0 \
      -DUSE_FFTW=1 \
      -DUSE_GRAPE=0 \
      -DUSE_C++11=0 \
      -DGENERATE_INCLUDE_TEST=0 \
      -DUSE_TIFF=1 \
      -DUSE_CIMG=0 \
      -DTEST_OPENSOURCE_SELECTION=0 \
      -DUSE_OPENGL=0 \
      -DUSE_METIS=0 \
      quocmesh
make
make test
make install
