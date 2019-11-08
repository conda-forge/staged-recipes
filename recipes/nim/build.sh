#!/usr/bin/env bash

# based on https://github.com/bioconda/bioconda-recipes/tree/master/recipes/pb-falconc

set -vexu -o pipefail

pushd nim
# inject compilers
echo "gcc.exe = \"$CC\"" >> config/nim.cfg
echo "gcc.linkerexe = \"$CC\"" >> config/nim.cfg
echo "clang.exe = \"$CC\"" >> config/nim.cfg
echo "clang.linkerexe = \"$CC\"" >> config/nim.cfg
./build.sh
bin/nim c koch
./koch tools

ls -larth
ls -larth bin/
ls -larth lib/
ls -larth config/

build_dir=$(pwd)

mkdir -p "${PREFIX}"
cd "${PREFIX}"
rsync -av "${build_dir}"/bin .
rsync -av "${build_dir}"/lib .
rsync -av "${build_dir}"/config .
