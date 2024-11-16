set -ex

# show available configure options
./configure --help

# seems to be running autoreconf for some reason
# try 'touch' to update timestamps to prevent autoreconf
ls -la
touch aclocal.m4 configure Makefile.am Makefile.in

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
