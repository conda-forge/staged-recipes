#!/usr/bin/env bash
set -ex

mkdir -p ${PREFIX}/share/conda-suggest
cp -v share/conda-suggest/conda-forge.noarch.map ${PREFIX}/share/conda-suggest
cp -v share/conda-suggest/conda-forge.${build_platform}.map ${PREFIX}/share/conda-suggest
