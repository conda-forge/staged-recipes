#!/bin/bash

set -o errexit -o pipefail

mkdir -p "${PREFIX}"/aarch64-conda_cos7-linux-gnu/sysroot/usr
pushd "${PREFIX}"/aarch64-conda_cos7-linux-gnu/sysroot/usr > /dev/null 2>&1
cp -Rf "${SRC_DIR}"/binary/* .
