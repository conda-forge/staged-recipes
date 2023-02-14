#!/bin/bash

# Install to conda style directories
[[ -d lib64 ]] && mv lib64 lib

[[ ${target_platform} == "linux-64" ]] && targetsDir="targets/x86_64-linux"
[[ ${target_platform} == "linux-ppc64le" ]] && targetsDir="targets/ppc64le-linux"
[[ ${target_platform} == "linux-aarch64" ]] && targetsDir="targets/sbsa-linux"

for i in `ls`; do
	[[ $i == "build_env_setup.sh" ]] && continue
	[[ $i == "conda_build.sh" ]] && continue
	[[ $i == "metadata_conda_debug.yaml" ]] && continue
	if [[ $i == "lib" ]]; then
		mkdir -p ${PREFIX}/${targetsDir}
		mkdir -p ${PREFIX}/$i/cmake
		cp -rv $i ${PREFIX}/${targetsDir}
		for j in `ls $i/cmake`; do
			ln -s ../../${targetsDir}/$i/cmake/$j ${PREFIX}/$i/cmake/$j
		done
	elif [[ $i == "include" ]]; then
		mkdir -p ${PREFIX}/${targetsDir}
		mkdir -p ${PREFIX}/$i
		cp -rv $i ${PREFIX}/${targetsDir}
		for j in `ls $i`; do
			ln -s ../${targetsDir}/$i/$j ${PREFIX}/$i/$j
		done
	else
		cp -rv $i ${PREFIX}
	fi
done
