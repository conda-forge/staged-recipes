
cd ARPACK
sh ./fixhome.sh
nmake lib

cd ..
cd SPOOLES.2.2
nmake lib -f makefile_MT

cd ..
cd CalculiX/ccx_2.12/src;
nmake -f Makefile_MT

cp ccx_2.12_MT %LIBRARY_PREFIX%/bin/ccx
cd $SRC_DIR