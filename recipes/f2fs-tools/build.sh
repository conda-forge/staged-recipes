set -ex

if [[ "$target_platform" == linux-* ]]
then
  # librt is required before glibc 2.17
  LDFLAGS="-lrt ${LDFLAGS}"
  # The FALLOC_FL_* flags are defined in glibc headers only since version 2.18.
  # https://github.com/torvalds/linux/blob/master/include/uapi/linux/falloc.h
  CFLAGS="-DFALLOC_FL_KEEP_SIZE=0x01 ${CFLAGS}"
  # https://github.com/torvalds/linux/blob/master/include/uapi/linux/fs.h
  CFLAGS="-DBLKSECDISCARD=_IO\\(0x12,125\\) ${CFLAGS}"
fi

./autogen.sh
./configure --prefix="${PREFIX}"
if [[ "$target_platform" == "win-64" ]]
then
  patch_libtool
fi
make -j${CPU_COUNT}
make install
