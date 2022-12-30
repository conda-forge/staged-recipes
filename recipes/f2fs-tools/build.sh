set -ex

./autogen.sh
./configure --prefix="${PREFIX}"
make
make install
