#!/bin/bash

# Find the recipes from upstream:main in this PR and remove them.
echo ""
echo "Finding recipes merged in main and removing them from the build."
pushd ./recipes > /dev/null
if [ "${CI:-}" != "" ]; then
  git fetch --force origin main:main
fi
shopt -s extglob dotglob
git ls-tree --name-only main -- !(example|example-v1) | xargs -I {} sh -c "rm -rf {} && echo Removing recipe: {}"
shopt -u extglob dotglob
popd > /dev/null
echo ""

build_me=false
for dr in $(ls recipes); do
    if [[ "${dr}" != "example" && "${dr}" != "example-v1" ]]; then
        build_me=true
    fi
done

if [[ "${build_me}" == "false" ]]; then
    echo "No recipes need to be built. Exiting!"
fi

echo "##vso[task.setvariable variable=buildMe;isOutput=true]${build_me}"
