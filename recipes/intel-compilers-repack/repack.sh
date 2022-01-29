#!/bin/bash
set -ex

# for subpackages, we have named our extracted locations according to the subpackage name
#    That's what this $PKG_NAME is doing - picking the right subfolder to rsync

src="${SRC_DIR}/${PKG_NAME}"

cp -rv "${src}"/* "${PREFIX}/"

# replace old info folder with our new regenerated one
rm -rf "${PREFIX}/info"

if [[ "$PKG_NAME" == "intel-fortran-rt" && "$target_platform" == "linux-"* ]]; then
  for f in "libicaf.so" "libifcoremt.so.5" "libifcore.so.5" "libifport.so.5"; do
    # Remove RUNPATH and keep only RPATH
    patchelf --set-rpath '$ORIGIN' --force-rpath ${PREFIX}/lib/$f
  done
fi

if [[ "$PKG_NAME" == "dpcpp_impl_linux-64" ]]; then
  # Not sure why these libraries are there, but seems to be unused.
  rm $PREFIX/lib/libffi.so*
fi
