set -ex

./autogen.sh
./configure --prefix="${PREFIX}"
if [[ "$target_platform" == "win-64" ]]
then
  patch_libtool
fi
make -j${CPU_COUNT}
make install
