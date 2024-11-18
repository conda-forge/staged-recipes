set -ex

# show available configure options
# ./configure --help

./configure \
  --with-libevent=$PREFIX \
  --with-hwloc=$PREFIX \
  --with-pmix=$PREFIX \
  --with-sge \
  --enable-ipv6 \
  --disable-dependency-tracking \
  --prefix=$PREFIX

make -j ${CPU_COUNT:-1}
make install
