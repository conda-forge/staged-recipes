mkdir -p $LIBRARY_PREFIX/lib/tclx8.6
./configure --exec-prefix=$LIBRARY_PREFIX/ --with-tcl=$LIBRARY_PREFIX/lib/ --with-help --enable-threads
make
make test
make install
cp library/*.tcl $LIBRARY_PREFIX/lib/tclx8.6/
cp tclx86.dll $LIBRARY_PREFIX/lib/tclx8.6/
cp pkgIndex.tcl $LIBRARY_PREFIX/lib/tclx8.6/

cd $LIBRARY_PREFIX/lib/tclx8.6/
ls -a
