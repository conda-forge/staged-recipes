#!/bin/bash

# Install to conda style directories
[[ -d lib64 ]] && mv lib64 lib
mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/lib/pkgconfig
[[ -d pkg-config ]] && mv pkg-config/* ${PREFIX}/lib/pkgconfig/
[[ -d "$PREFIX/lib/pkgconfig" ]] && sed -E -i "s|cudaroot=.+|cudaroot=$PREFIX|g" $PREFIX/lib/pkgconfig/cuobjclient*.pc

[[ ${target_platform} == "linux-64" ]] && targetsDir="targets/x86_64-linux"
[[ ${target_platform} == "linux-aarch64" ]] && targetsDir="targets/sbsa-linux"

for i in `ls`; do
    [[ $i == "build_env_setup.sh" ]] && continue
    [[ $i == "conda_build.sh" ]] && continue
    [[ $i == "metadata_conda_debug.yaml" ]] && continue

    if [[ $i == "lib" ]] || [[ $i == "include" ]]; then
        mkdir -p ${PREFIX}/${targetsDir}
        mkdir -p ${PREFIX}/$i
        cp -rv $i ${PREFIX}/${targetsDir}
        if [[ $i == "lib" ]]; then
            for j in "$i"/*.so*; do
                echo j = $j
                [[ -L ${PREFIX}/$j ]] && continue

                # Shared libraries are symlinked in $PREFIX/lib
                echo ln -s ${PREFIX}/${targetsDir}/$j ${PREFIX}/$j
                ln -s ${PREFIX}/${targetsDir}/$j ${PREFIX}/$j

                echo patchelf --set-rpath '$ORIGIN' --force-rpath ${PREFIX}/${targetsDir}/$j
                patchelf --set-rpath '$ORIGIN' --force-rpath ${PREFIX}/${targetsDir}/$j
            done
        fi
    else
        # Put all other files in targetsDir
        mkdir -p ${PREFIX}/${targetsDir}/libcuobjclient
        cp -rv $i ${PREFIX}/${targetsDir}/libcuobjclient
    fi
done

check-glibc "$PREFIX"/lib*/*.so.* "$PREFIX"/bin/* "$PREFIX"/targets/*/lib*/*.so.* "$PREFIX"/targets/*/bin/*
