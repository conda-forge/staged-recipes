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
    if [[ $i == "bin" ]] || [[ $i == "lib" ]] || [[ $i == "include" ]] || [[ $i == "nvvm" ]]; then
        # Headers and libraries are installed to targetsDir
        mkdir -p ${PREFIX}/${targetsDir}
        mkdir -p ${PREFIX}/$i
        if [[ $i == "bin" ]]; then
            mkdir -p ${PREFIX}/${targetsDir}/bin
            cp -rv $i ${PREFIX}
            ln -sv ${PREFIX}/bin/nvcc ${PREFIX}/${targetsDir}/bin/nvcc
        elif [[ $i == "lib" ]]; then
            cp -rv $i ${PREFIX}/${targetsDir}
            for j in "$i"/*.a*; do
                # Static libraries are symlinked in $PREFIX/lib
                ln -sv ${PREFIX}/${targetsDir}/$j ${PREFIX}/$j
            done
            ln -sv ${PREFIX}/${targetsDir}/lib ${PREFIX}/${targetsDir}/lib64
        elif [[ $i == "include" ]]; then
            cp -rv $i ${PREFIX}/${targetsDir}
        elif [[ $i == "nvvm" ]]; then
            cp -rv $i ${PREFIX}
            ln -sv ${PREFIX}/nvvm ${PREFIX}/${targetsDir}/nvvm
        fi
    else
        cp -rv $i ${PREFIX}/${targetsDir}
    fi
done

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
# Name this script starting with `~` so it is run after all other compiler activation scripts.
# At the point of running this, $CXX must be defined.
# for CHANGE in "activate" "deactivate"
# do
#     mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
#     cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/~cuda-nvcc_${CHANGE}.sh"
# done
