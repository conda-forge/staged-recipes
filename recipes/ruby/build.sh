set -e
set -x

./configure --prefix=$PREFIX --disable-install-doc
make -j ${CPU_COUNT}
make check
make install
