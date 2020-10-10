aclocal
autoconf
( cd testsuite
  autoconf -I.. )

./configure --prefix=$PREFIX --build=$BUILD --host=$HOST --with-tclinclude=$PREFIX/include
make -j ${CPU_COUNT}
make test
make -j ${CPU_COUNT} install

mv $PREFIX/lib/tcl*/expect${PKG_VERSION}/libexpect${PKG_VERSION}.so $PREFIX/lib
ln -s libexpect${PKG_VERSION}.so $PREFIX/lib/libexpect.so
