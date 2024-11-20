#!/bin/bash

# Relocate CUDA major specific libraries to single prefix layout
export CUDA_MAJOR=${cuda_compiler_version%%.*}
mv -v lib lib.backup
mv -v lib.backup/${CUDA_MAJOR} lib
rm -rv lib.backup

# Install to conda style directories
[[ -d lib64 ]] && mv lib64 lib
mkdir -p ${PREFIX}/lib
[[ -d pkg-config ]] && mv pkg-config ${PREFIX}/lib/pkgconfig
[[ -d "$PREFIX/lib/pkgconfig" ]] && sed -E -i "s|cudaroot=.+|cudaroot=$PREFIX|g" $PREFIX/lib/pkgconfig/nvjpeg*.pc

for i in `ls`; do
    [[ $i == "build_env_setup.sh" ]] && continue
    [[ $i == "conda_build.sh" ]] && continue
    [[ $i == "metadata_conda_debug.yaml" ]] && continue
    cp -rv $i ${PREFIX}
done
