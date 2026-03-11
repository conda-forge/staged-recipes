#!/bin/bash
set -x -e -u -o pipefail
# Install to conda style directories
[[ -d lib64 ]] && mv lib64 lib
mkdir -p "${PREFIX}/lib"
[[ -d pkg-config ]] && mv pkg-config ${PREFIX}/lib/pkgconfig
[[ -d "$PREFIX/lib/pkgconfig" ]] && sed -E -i "s|cudaroot=.+|cudaroot=$PREFIX|g" $PREFIX/lib/pkgconfig/cudla*.pc

[[ ${target_platform} == "linux-64" ]] && targetsDir="targets/x86_64-linux"
[[ ${target_platform} == "linux-aarch64" ]] && targetsDir="targets/sbsa-linux"

for i in `ls`; do
    [[ $i == "build_env_setup.sh" ]] && continue
    [[ $i == "conda_build.sh" ]] && continue
    [[ $i == "metadata_conda_debug.yaml" ]] && continue
    if [[ $i == "lib" ]] || [[ $i == "include" ]]; then
        # Headers and libraries are installed to targetsDir
        mkdir -p ${PREFIX}/${targetsDir}
        mkdir -p ${PREFIX}/$i
        cp -rv $i ${PREFIX}/${targetsDir}
        if [[ $i == "lib" ]]; then
            for j in "$i"/*.so*; do
                # Shared libraries are symlinked in $PREFIX/lib
                ln -sv ${PREFIX}/${targetsDir}/$j ${PREFIX}/$j

                if [[ $j =~ \.so\. ]]; then
                    patchelf --set-rpath '$ORIGIN' --force-rpath ${PREFIX}/${targetsDir}/$j
                fi
            done
        fi
    else
        # Put all other files in targetsDir
        mkdir -p ${PREFIX}/${targetsDir}/libcudla
        cp -rv $i ${PREFIX}/${targetsDir}/libcudla
    fi
done

check-glibc "$PREFIX"/lib*/*.so.* "$PREFIX"/bin/* "$PREFIX"/targets/*/lib*/*.so.* "$PREFIX"/targets/*/bin/*
