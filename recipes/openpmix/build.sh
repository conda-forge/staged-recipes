set -ex

# touch generated files to prevent unnecessary invocation of automake
touch Makefile.in configure

# show available configure options
# ./configure --help

./configure \
  --with-libevent=$PREFIX \
  --with-hwloc=$PREFIX \
  --enable-ipv6 \
  --disable-dependency-tracking \
  --prefix=$PREFIX

make -j ${CPU_COUNT:-1}
make install
