./configure --host=x86_64-unknown-cygwin --build=x86_64-unknown-cygwin --disable-dependency-tracking  --sysconfdir=/etc --exec-prefix=$PREFIX/lib/tcl8.6/ --datadir=/usr/share --libexecdir=/usr/libexec --localstatedir=/usr/var --sharedstatedir=/usr/com --mandir=/usr/share/man --infodir=/usr/share/info --with-tcl=$LIBRARY_PREFIX/lib/ --with-help --enable-threads
echo "make"
make
echo "make test"
pwd
make test
echo "make install"
make install
echo "Finished installing"
pwd
echo find . -name 'autoload'
