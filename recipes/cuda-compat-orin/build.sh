#!/bin/bash

set -ex

# Install to conda style directories
[[ -d lib64 ]] && mv lib64 lib
mkdir -p ${PREFIX}/cuda-compat

# The redistributable unpacks its libraries into "compat", except the Tegra one which uses
# "compat_orin".
compat_dirs=(compat*/)
if [[ ${#compat_dirs[@]} -ne 1 || ! -d ${compat_dirs[0]} ]]; then
  echo "Expected exactly one compat directory, found: ${compat_dirs[*]}" >&2
  exit 1
fi
COMPAT_DIR=${compat_dirs[0]}

check-glibc ${COMPAT_DIR}/*.so*

cp -vd ${COMPAT_DIR}/*.so* ${PREFIX}/cuda-compat/
