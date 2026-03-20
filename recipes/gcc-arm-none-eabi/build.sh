#!/bin/bash

export TARGET=arm-none-eabi
export TARGET_PREFIX="${PREFIX}/${TARGET}"

mkdir -p "${PREFIX}"/bin
mkdir -p "${TARGET_PREFIX}"

cp -R $SRC_DIR/* $TARGET_PREFIX

# Drop the Python-embedded GDB launcher because it hardcodes link to custom python
rm -f "${TARGET_PREFIX}/bin/arm-none-eabi-gdb-py"

# Symlink every binary from the build into /bin
pushd "${PREFIX}"/bin
    ln -s ../"${TARGET}"/bin/* ./
popd
