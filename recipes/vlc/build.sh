set -ex

./bootstrap
./configure \
  --enable-qt \
  --disable-a52 \
  --disable-wayland \
  --prefix=${PREFIX}

make -j${CPU_COUNT}
make -j${CPU_COUNT} install
