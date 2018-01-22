./configure --prefix=$PREFIX --with-pic

#make -j ${CPU_COUNT}
make 
make check || true
make install
