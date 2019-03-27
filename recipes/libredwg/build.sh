autoreconf --install --symlink -I m4
sh autogen.sh
./configure --prefix=$PREFIX
make
make install