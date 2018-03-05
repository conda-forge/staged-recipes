./autogen.sh
./configure --prefix=$LIBRARY_PREFIX
make install -j${CPU_COUNT}