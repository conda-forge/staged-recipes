cd ccx*/src
rm Makefile_MT

if [ `uname` = "Darwin" ]; then
    cp ${RECIPE_DIR}/Makefile_MT_osx Makefile_MT
else
    cp ${RECIPE_DIR}/Makefile_MT_linux Makefile_MT
fi

make -f Makefile_MT
cp ccx_*_MT $PREFIX/bin/ccx
cd $SRC_DIR