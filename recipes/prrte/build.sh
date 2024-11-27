set -ex

./configure \
  --with-libevent=$PREFIX \
  --with-hwloc=$PREFIX \
  --with-pmix=$PREFIX \
  --with-sge \
  --enable-ipv6 \
  --enable-prte-prefix-by-default \
  --disable-dependency-tracking \
  --prefix=$PREFIX

make -j ${CPU_COUNT:-1}
make install
