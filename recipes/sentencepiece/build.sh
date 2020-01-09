mkdir build
cd build

export LD_LIBRARY_PATH=${PREFIX}/lib
export CPATH=${PREFIX}/include
export INCLUDE=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib \
    -DCMAKE_AR="${AR}" \
    -DSPM_ENABLE_TCMALLOC=OFF \
    -S ..

make -j $(nproc)
make install

ldconfig -v -N
cd $SRC_DIR/python
${PYTHON} setup.py build
${PYTHON} setup.py install
