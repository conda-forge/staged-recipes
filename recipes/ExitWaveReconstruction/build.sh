#!/bin/bash
cmake -G"Unix Makefiles" \
    -IFLAGS="-I${PREFIX}/include"
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_CXX_FLAGS=${CXXFLAGS} \
    -DCMAKE_C_FLAGS=${CFLAGS} \
    -DGCC_SYSTEM_TYPE="" \
    -DC++_STANDARD=C++11 \
    -DCMAKE_BUILD_TYPE=Release \
    -DDYNAMIC_LINKING=1 \
    -DPARSE_GCC_ERRORS=1 \
    -DUSE_OPENMP=1 \
    -DUSE_FFTW=1 \
    -DUSE_BOOST=1 \
    -DUSE_OPENCL=1 \
    -DUSE_TIFF=1 \
    -DUSE_DOXYGEN=0 \
    Src
make -j${CPU_COUNT}
make test
make install

mkdir ${PREFIX}/bin
ln ${PREFIX}/Bin/projects/ExitWaveReconstruction/Reconstruction ${PREFIX}/bin
