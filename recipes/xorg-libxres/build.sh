set -x

autoreconf -ivf

./configure
make
make install
