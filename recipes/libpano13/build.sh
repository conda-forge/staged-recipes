set -ex

./configure \
    --prefix=${PREFIX} \
    --with-zlib=${PREFIX} \
    --with-java=${JAVA_HOME}

cat config.log
cat Makefile

make -j${CPU_COUNT}

make install
