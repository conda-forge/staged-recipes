./bootstrap.sh
./configure --datadir=$PREFIX/share/libpostal_data --prefix=$PREFIX

make -j${CPU_COUNT}
make install
