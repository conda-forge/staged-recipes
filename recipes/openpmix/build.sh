set -ex

# show available configure options
./configure --help

./configure \
  --with-libevent=$PREFIX \
  --with-hwloc=$PREFIX \
  --enable-ipv6 \
  --disable-dependency-tracking \
  --prefix=$PREFIX

make -j ${CPU_COUNT:-1}
make install
# don't install HTML docs
rm -rf $PREFIX/share/doc/pmix
