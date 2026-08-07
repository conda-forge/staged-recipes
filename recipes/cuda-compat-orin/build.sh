#!/bin/bash

set -ex

mkdir -p "${PREFIX}/cuda-compat"

# Unlike the other CUDA compat redistributables, this one unpacks into "compat_orin".
COMPAT_DIR=compat_orin

# The archive is the only place where the user-mode driver version shows up: the redistrib
# manifest reports the CUDA release (13.3.45405995) instead, and the version is not written in
# any text file, only in the library file names. It cannot be recovered at render time either,
# conda-build's load_file_regex opens the file as text and these are ELF objects. So it is
# spelled out in meta.yaml and verified here, to fail the build rather than publish a package
# whose version does not match the driver it ships.
detected_version=$(
  printf '%s\n' "${COMPAT_DIR}"/libnvidia-nvvm.so.* |
    sed -n 's|.*/libnvidia-nvvm\.so\.\([0-9][0-9]*\.[0-9][0-9]*\)$|\1|p'
)

if [[ ${detected_version} != "${DRV_VERSION}" ]]; then
  echo "Driver version mismatch: meta.yaml declares '${DRV_VERSION}'," \
       "the archive ships '${detected_version}'" >&2
  exit 1
fi

check-glibc ${COMPAT_DIR}/*.so*

cp -vd ${COMPAT_DIR}/*.so* "${PREFIX}/cuda-compat/"
