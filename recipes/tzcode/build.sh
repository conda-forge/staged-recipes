tar xvf tzdb-$PKG_VERSION.tar.lz --strip 1

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
