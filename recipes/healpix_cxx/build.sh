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
