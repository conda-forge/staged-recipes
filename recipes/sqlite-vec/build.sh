sed -i 's;\/usr\/local;\$(PREFIX);g' Makefile
sed -i 's;prefix=dist;prefix?=dist;g' Makefile

cat Makefile

export LDFLAGS="$LDFLAGS -L${PREFIX}/lib"

export CFLAGS="$CFLAGS -I${PREFIX}/include"

make all PREFIX=$PREFIX CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
make install PREFIX=$PREFIX
