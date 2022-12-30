set -ex

if [[ "$target_platform" == linux-* ]]
then
  # librt is required before glibc 2.17
  LDFLAGS="-lrt ${LDFLAGS}"
fi

./autogen.sh
./configure --prefix="${PREFIX}"
if [[ "$target_platform" == "win-64" ]]
then
  patch_libtool
fi
make -j${CPU_COUNT}
make install
