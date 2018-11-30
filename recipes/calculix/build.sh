cd ccx*/src
rm Makefile_MT
cp ${RECIPE_DIR}/Makefile_MT Makefile_MT

make -f Makefile_MT
cp ccx_*_MT $PREFIX/bin/ccx \
    SPOOLES_INCLUDE_DIR="${PREFIX}/include/spooles" \
    LIB_DIR="${PREFIX}/lib"
cd $SRC_DIR
