set -x

./configure --prefix=${PREFIX} && \
make MAKEINFO=true && \
make install