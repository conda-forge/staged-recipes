CP %BUILD_PREFIX%\Library\mingw-w64\bin\mingw32-make %BUILD_PREFIX%\Library\mingw-w64\bin\make

cd ccx*/src
make -f Makefile_MT

cp ccx_*_MT $PREFIX/bin/ccx
cd $SRC_DIR
