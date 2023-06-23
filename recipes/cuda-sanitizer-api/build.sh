#!/bin/bash

# Install to conda style directories
[[ -d lib64 ]] && mv lib64 lib

# Remove 32bit libraries
[[ -d "compute-sanitizer/x86" ]] && rm -rf compute-sanitizer/x86/

for i in `ls`; do
    [[ $i == "build_env_setup.sh" ]] && continue
    [[ $i == "conda_build.sh" ]] && continue
    [[ $i == "metadata_conda_debug.yaml" ]] && continue
    cp -r $i ${PREFIX}
done
