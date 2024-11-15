set -ex

# show available configure options
./configure --help

./configure \
  --with-pmix=$PREFIX \
  --with-libevent=$PREFIX \
  --with-hwloc=$PREFIX \
  --enable-ipv6 \
  --enable-sge \
  --disable-dependency-tracking \
  --prefix=$PREFIX

make -j ${CPU_COUNT:-1}
make install
