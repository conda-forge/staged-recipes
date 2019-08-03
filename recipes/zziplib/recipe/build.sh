./configure --prefix=$PREFIX

make VERBOSE=1 -j${CPU_COUNT}
make install
