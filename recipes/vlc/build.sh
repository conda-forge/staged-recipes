set -ex

# They need a c99 compiler...
# Replace the ending -cc ${CC} with -c99
export BUILDCC="$(echo ${CC} | sed 's/-cc$//')-c99"

# Seems like there is a bug in the C99 script
sed -i "s,^exec gcc ,exec ${CC} ," ${BUILDCC}
./bootstrap
./configure \
  --enable-qt \
  --disable-a52 \
  --disable-wayland \
  --prefix=${PREFIX}

make -j${CPU_COUNT}
make -j${CPU_COUNT} install
