set -euxo pipefail
autoreconf -i
./configure
make && make install