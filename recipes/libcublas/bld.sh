#!/bin/bash

echo "Where are we?"
pwd
echo "What is here?"
ls

# Install to conda style directories
[[ -d lib64 ]] && mv lib64 lib

for i in `ls`; do
	[[ $i == "build_env_setup.sh" ]] && continue
	[[ $i == "conda_build.sh" ]] && continue
	[[ $i == "metadata_conda_debug.yaml" ]] && continue
	cp -r $i ${PREFIX}
done
