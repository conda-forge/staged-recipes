# configure tool is mixing CXXFLAGS with CPPFLAGS
export CFLAGS="${CFLAGS} ${CPPFLAGS}"

./configure \
  --prefix=$PREFIX  \
  --with-readline=gnu \
  --without-ncurses \
  --with-pcre \
  --with-onig \
  --with-png \
  --with-z \
  --with-iconv=$PREFIX

make
make check
make install
