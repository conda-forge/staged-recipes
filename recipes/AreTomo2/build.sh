cp ${PREFIX}/LibSrc/Lib/libmrcfile.a ${PREFIX}/lib/
cp ${PREFIX}/LibSrc/Lib/libutil.a ${PREFIX}/lib/
echo `ls ${PREFIX}/lib`
make exe -f makefile11 CUDAHOME=$BUILD_PREFIX
cp AreTomo2 ${PREFIX}/bin/
