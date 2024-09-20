sed -i 's;\/usr\/local;\$(PREFIX);g' Makefile
sed -i 's;prefix=dist;prefix?=dist;g' Makefile
sed -i 's;all: [^$]*;all: loadable;' Makefile
sed -i 's;ldconfig;;' Makefile

cat Makefile

export LDFLAGS="$LDFLAGS -L${PREFIX}/lib"

export CFLAGS="$CFLAGS -I${PREFIX}/include"

make all PREFIX=$PREFIX CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
make install PREFIX=$PREFIX
make test-loadable
find dist -type f
