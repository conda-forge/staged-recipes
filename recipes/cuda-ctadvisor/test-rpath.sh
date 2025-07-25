#!/bin/bash

[[ ${target_platform} == "linux-64" ]] && targetsDir="targets/x86_64-linux"
[[ ${target_platform} == "linux-ppc64le" ]] && targetsDir="targets/ppc64le-linux"
# https://docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html?highlight=tegra#cross-compilation
[[ ${target_platform} == "linux-aarch64" && ${arm_variant_type} == "sbsa" ]] && targetsDir="targets/sbsa-linux"
[[ ${target_platform} == "linux-aarch64" && ${arm_variant_type} == "tegra" ]] && targetsDir="targets/aarch64-linux"

errors=""

for bin in `find ${PREFIX}/bin -type f`; do
    [[ "${bin}" =~ "patchelf" ]] && continue

    filename=$(basename "${bin}")
    echo "Artifact to test: ${filename}"

    pkg_info=$(conda package -w "${bin}")
    echo "\$PKG_NAME: ${PKG_NAME}"
    echo "\$pkg_info: ${pkg_info}"

    if [[ ! "$pkg_info" == *"$PKG_NAME"* ]]; then
        echo "Not a match, skipping ${bin}"
        continue
    fi

    echo "Match found, testing ${bin}"

    rpath=$(patchelf --print-rpath "${bin}")
    echo "${bin} rpath: ${rpath}"

    if [[ $rpath != "\$ORIGIN/../lib:\$ORIGIN/../${targetsDir}/lib" ]]; then
        errors+="${bin}\n"
    elif [[ $(objdump -x ${bin} | grep "PATH") == *"RUNPATH"* ]]; then
        errors+="${bin}\n"
    fi
done

if [[ $errors ]]; then
    echo "The following binaries were found with an unexpected RPATH:"
    echo -e "${errors}"
    exit 1
fi
