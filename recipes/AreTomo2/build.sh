cp ${SRC_DIR}/LibSrc/Lib/libmrcfile.a ${PREFIX}/lib/
cp ${SRC_DIR}/LibSrc/Lib/libutil.a ${PREFIX}/lib/
make exe -f makefile11 CUDAHOME=$BUILD_PREFIX
cp ${SRC_DIR}/AreTomo2 ${PREFIX}/bin/
