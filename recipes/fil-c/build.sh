#!/bin/bash
set -euxo pipefail

# Keep the upstream release layout intact: the clang driver locates the Fil-C
# runtime at <real-path-of-clang>/../../pizfix.
DEST="${PREFIX}/lib/fil-c"
mkdir -p "${DEST}"
cp -a build pizfix README.md "${DEST}/"

# Upstream's setup.sh sets these rpaths to absolute paths of the unpack
# location; use $ORIGIN-relative rpaths instead so the tree is relocatable.
patchelf --set-rpath '$ORIGIN' "${DEST}/pizfix/lib/libc.so"
patchelf --set-rpath '$ORIGIN' "${DEST}/pizfix/lib/libpizlo.so"
patchelf --set-rpath '$ORIGIN' "${DEST}/pizfix/lib/libc++.so.1.0"
patchelf --set-rpath '$ORIGIN' "${DEST}/pizfix/lib/libc++abi.so.1.0"
patchelf --set-rpath '$ORIGIN/../lib' "${DEST}/pizfix/lib_test/libpizlo.so"
patchelf --set-rpath '$ORIGIN/../lib' "${DEST}/pizfix/lib_test_gcverify/libpizlo.so"
patchelf --set-rpath '$ORIGIN/../lib' "${DEST}/pizfix/lib_gcverify/libpizlo.so"

# Upstream's setup.sh symlinks the system kernel headers (/usr/include/linux,
# asm, asm-generic) into pizfix/os-include; point at the conda kernel headers
# from kernel-headers_linux-64 instead.
mkdir -p "${DEST}/pizfix/os-include"
for dir in linux asm asm-generic; do
  ln -s "../../../../x86_64-conda-linux-gnu/sysroot/usr/include/${dir}" \
    "${DEST}/pizfix/os-include/${dir}"
done

# The clang driver needs a GNU ld for linking (upstream assumes system
# binutils); the driver searches its own directory first, so link the conda
# ld from ld_impl_linux-64 next to clang-20.
ln -s ../../../../x86_64-conda-linux-gnu/bin/ld "${DEST}/build/bin/ld"

# Expose the Fil-C driver names, but not the clang/clang++ symlinks, which
# would collide with the clang packages.
mkdir -p "${PREFIX}/bin"
for tool in filcc fil++ filcpp; do
  ln -s "../lib/fil-c/build/bin/${tool}" "${PREFIX}/bin/${tool}"
done
