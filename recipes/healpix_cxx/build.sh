#export CFITSIO_CFLAGS="-I${PREFIX}/include"
if [ "$(uname)" == "Darwin" ]; then
    
    export CC=clang
    export CXX=clang++
    
else

    export CC=${PREFIX}/bin/gcc
    export CXX=${PREFIX}/bin/g++

fi

cd src/cxx

export CFLAGS="-fPIC ${CFLAGS}"
export CXXFLAGS="-fPIC ${CXXFLAGS}"
export CPATH="${PREFIX}/include"

autoconf

./configure --prefix=$PREFIX --enable-noisy-make

make -j ${CPU_COUNT}

# There is no "make install", so we do it manually
cp -r auto/lib/* ${PREFIX}/lib
mkdir ${PREFIX}/include/healpix_cxx
cp -r auto/include/* ${PREFIX}/include/healpix_cxx
cp -r auto/bin/* ${PREFIX}/bin
