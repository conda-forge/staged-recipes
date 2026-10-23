#!/usr/bin/env bash
set -euxo pipefail

# The runtime keeps the toolchain's layout so that the compiler finds it as
# part of its resource directory. rattler-build strips the single top-level
# directory from the Linux archive.
runtime_dir="${PREFIX}/libexec/swift/usr/lib/swift/linux"
mkdir -p "${runtime_dir}"
cp -P "${SRC_DIR}"/usr/lib/swift/linux/*.so "${runtime_dir}/"
