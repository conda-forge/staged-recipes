./bootstrap.sh
./configure --datadir=$PREFIX/lib/libpostal_data --prefix=$PREFIX

make
make install
