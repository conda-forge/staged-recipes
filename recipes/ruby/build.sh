set -e
set -x

./configure --prefix=$PREFIX
make -j ${CPU_COUNT}
make check
make install
