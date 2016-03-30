# Generated from configure on the build machine, and then modified to pick up
# the shared libraries in /usr/local (which is replaced with $PREFIX)

# ./configure
if [ "$(uname)" == "Darwin" ]; then
	cp $RECIPE_DIR/config.mk.mac config.mk
fi
if [ "$(uname)" == "Linux" ]; then
	cp $RECIPE_DIR/config.mk.linux config.mk
fi

sed -i -e "s:/usr/local:$PREFIX:g" config.mk

make
make package pkgdir=$SRC_DIR/pkg
# make check pkgdir=$SRC_DIR/pkg

# The netpbm install script is interactive, so just install it manually
# ./installnetpbm
mkdir -p $PREFIX/bin/
mkdir -p $PREFIX/lib/
mkdir -p $PREFIX/include/
mkdir -p $PREFIX/share/man1/
mkdir -p $PREFIX/share/man3/
mkdir -p $PREFIX/share/man5/
mkdir -p $PREFIX/share/web/
cp -R pkg/bin/* $PREFIX/bin/
cp -R pkg/lib/* $PREFIX/lib/
cp -R pkg/link/* $PREFIX/lib/
cp -R pkg/include/* $PREFIX/include/
cp -R pkg/man/man1/* $PREFIX/share/man1/
cp -R pkg/man/man3/* $PREFIX/share/man3/
cp -R pkg/man/man5/* $PREFIX/share/man5/
cp -R pkg/man/web/* $PREFIX/share/web/
