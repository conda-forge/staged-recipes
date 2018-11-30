cd ccx*/src

rm Makefile_MT
cp %RECIPE_DIR%\Makefile_MT_windows Makefile_MT

CP %BUILD_PREFIX%\Library\mingw-w64\bin\mingw32-make %BUILD_PREFIX%\Library\mingw-w64\bin\make

make -f Makefile_MT

cp ccx_*_MT $PREFIX/bin/ccx
cd $SRC_DIR
