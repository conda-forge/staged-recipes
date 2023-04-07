#!/bin/bash

# Install to conda style directories
[[ -d lib64 ]] && mv lib64 lib

[[ ${target_platform} == "linux-64" ]] && targetsDir="targets/x86_64-linux"
[[ ${target_platform} == "linux-ppc64le" ]] && targetsDir="targets/ppc64le-linux"
[[ ${target_platform} == "linux-aarch64" ]] && targetsDir="targets/sbsa-linux"

mkdir -p ${PREFIX}/${targetsDir}

cp -rv lib ${PREFIX}/${targetsDir}
cp -rv include ${PREFIX}/${targetsDir}
