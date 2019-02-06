export CXXFLAGS="${CXXFLAGS} -std=c++11"

./configure \
    --prefix="${PREFIX}" \
    --with-openssl="${PREFIX}/" \
    --with-zlib="${PREFIX}/" \
    --enable-ipv6

make -j1
