#!/bin/bash

echo "ENVIRONMENT:"
env

# Install to conda style directories
[[ -d lib64 ]] && mv lib64 lib
mkdir -p ${PREFIX}/lib
[[ -d pkg-config ]] && mv pkg-config ${PREFIX}/lib/pkgconfig
[[ -d "$PREFIX/lib/pkgconfig" ]] && sed -E -i "s|cudaroot=.+|cudaroot=$PREFIX|g" $PREFIX/lib/pkgconfig/cublas*.pc

[[ ${target_platform} == "linux-64" ]] && targetsDir="targets/x86_64-linux"
[[ ${target_platform} == "linux-ppc64le" ]] && targetsDir="targets/ppc64le-linux"
[[ ${target_platform} == "linux-aarch64" ]] && targetsDir="targets/sbsa-linux"

for i in `ls`; do
    [[ $i == "build_env_setup.sh" ]] && continue
    [[ $i == "conda_build.sh" ]] && continue
    [[ $i == "metadata_conda_debug.yaml" ]] && continue
    # Headers and libraries are installed to targetsDir
    if [[ $i == "lib" ]] || [[ $i == "include" ]]; then
        mkdir -p ${PREFIX}/${targetsDir}
        mkdir -p ${PREFIX}/$i
        cp -rv $i ${PREFIX}/${targetsDir}
        # Shared libraries are symlinked in $PREFIX/lib
        if [[ $i == "lib" ]]; then
            for j in "$i"/*.so*; do
                ln -s ../${targetsDir}/$i/$j ${PREFIX}/$i/$j
            done
        fi
    else
        # Put all other files (Fortran bindings in src, LICENSE) in targetsDir
        cp -rv $i ${PREFIX}/${targetsDir}/libcublas/$i
    fi
done
