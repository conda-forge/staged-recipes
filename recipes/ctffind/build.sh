tar -xv tdf?path=ctffind-4.1.14.tar.gz&file=1&type=node&id=26
cd ctffind-4.1.4

./configure \
--prefix $PREFIX \
--srcdir=$SRC_DIR \
--enable-mkl \
--enable-openmp \
--enable-shared \
--enable-static no

make -j $CPU_COUNT && make install

ls $PREFIX/bin  # debug
