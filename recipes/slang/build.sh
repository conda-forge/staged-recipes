# configure tool is mixing CXXFLAGS with CPPFLAGS
export CFLAGS="${CFLAGS} ${CPPFLAGS}"

./configure \
  --prefix=$PREFIX  \
  --with-readline=gnu
make
make install
