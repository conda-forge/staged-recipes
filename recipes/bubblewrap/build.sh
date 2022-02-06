sh autogen.sh

./configure --prefix=$PREFIX --enable-man=no

make -j${CPU_COUNT}
make install
