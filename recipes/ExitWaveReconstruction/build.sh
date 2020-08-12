#!/bin/bash
cmake -G"Unix Makefiles" \
    -IFLAGS="-I${PREFIX}/include" \
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
    -DUSE_CIMG=1 \
    Src
make -j${CPU_COUNT}
make test
make install

mv ${PREFIX}/bin/projects/ExitWaveReconstruction/Reconstruction ${PREFIX}/bin
mv ${PREFIX}/bin/tools/image/converter/convert* ${PREFIX}/bin

rm -rf ${PREFIX}/bin/tools
rm -rf ${PREFIX}/bin/projects
rm -rf ${PREFIX}/bin/selfTest
