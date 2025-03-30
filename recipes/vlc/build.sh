set -ex

# They need a c99 compiler...
# Replace the ending -cc ${CC} with -c99
export BUILDCC="$(echo ${CC} | sed 's/-cc$//')-c99"
./bootstrap
./configure \
  --enable-qt \
  --disable-a52 \
  --disable-wayland \
  --prefix=${PREFIX}

make -j${CPU_COUNT}
make -j${CPU_COUNT} install
