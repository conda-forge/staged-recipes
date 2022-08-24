ls  # debug

./configure \
--prefix $PREFIX \
--srcdir=$SRC_DIR \
--enable-mkl \
--enable-openmp \
--enable-shared \
--enable-static no

make -j $CPU_COUNT && make install

ls $PREFIX/bin  # debug
