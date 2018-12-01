if [ ! -e tzdb-$PKG_VERSION.tar.lz ]; then
    wget https://data.iana.org/time-zones/releases/tzdb-${PKG_VERSION}.tar.lz
fi
lzip -d tzdb-$PKG_VERSION.tar.lz

tar xvf tzdb-$PKG_VERSION.tar --strip 1

mkdir dest
make -e \
  cc=$CC \
  DESTDIR=dest \
  TOPDIR=$PREFIX \
  USRDIR=. \
  install

prefix_num_dirs=$(echo $PREFIX | grep -o / | wc -l)
tar cf - -C dest . | tar xf - -C $PREFIX --strip $(( prefix_num_dirs + 1 ))

mv $PREFIX/sbin/zic $PREFIX/bin
