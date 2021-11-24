./configure --host=x86_64-unknown-cygwin --build=x86_64-unknown-cygwin --disable-dependency-tracking --exec-prefix=$PREFIX/Library/lib --sysconfdir=/etc --datadir=/usr/share --libexecdir=/usr/libexec --localstatedir=/usr/var --sharedstatedir=/usr/com --mandir=/usr/share/man --infodir=/usr/share/info --with-tcl=$LIBRARY_PREFIX/lib/ --with-help --enable-threads
make
make install

