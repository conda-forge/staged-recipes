set -ex

./configure --prefix="${PREFIX}"
make
make check
make install
