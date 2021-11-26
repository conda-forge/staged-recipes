mkdir -p $LIBRARY_PREFIX/lib/tclx8.6
echo "created new folder"
./configure --exec-prefix=$LIBRARY_PREFIX/ --with-tcl=$LIBRARY_PREFIX/lib/ --with-help --enable-threads
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
