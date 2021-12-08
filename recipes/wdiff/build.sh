set -x

./configure --prefix=${PREFIX}
make
make check
make install
make installcheck
