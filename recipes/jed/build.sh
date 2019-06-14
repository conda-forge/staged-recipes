# This install is just for terminal version of jed.
./configure --prefix=$PREFIX

make clean
make jed
make rgrep
#make xjed
make install
