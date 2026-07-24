#!/bin/bash
set -euxo pipefail

# Reclaim disk space: the tarball carries benchmark data, LLVM subprojects
# and ported-project sources that the base toolchain build does not need.
# yolomusl/usermusl must stay: they are the Fil-C libc.
rm -rf benchmarkData pizlix optfil bolt clang-tools-extra flang lldb mlir polly
for d in projects/*; do
  case "$d" in
    projects/yolomusl | projects/usermusl) ;;
    *) rm -rf "$d" ;;
  esac
done

# CI has 2 cores / ~7 GB RAM: build Release instead of RelWithDebInfo and
# serialize the large LLVM link steps to avoid running out of memory.
sed -i 's/-DCMAKE_BUILD_TYPE=RelWithDebInfo/-DCMAKE_BUILD_TYPE=Release -DLLVM_PARALLEL_LINK_JOBS=1/' configure_llvm.sh

# build_clang.sh/build_cxx.sh/build_compiler_rt.sh source this hook if present
cat > clang-build-overrides.sh <<'EOF'
NINJAFLAGS="-j 2"
NINJARUNTIMEFLAGS="-j 2"
EOF

# The steps of upstream's build_base.sh, except build_os_include.sh, which
# symlinks /usr/include kernel headers; use the conda sysroot ones instead.
./build_compiler_rt.sh
./build_yolounwind.sh
./configure_llvm.sh
./build_clang.sh
mkdir -p pizfix/os-include
for dir in linux asm asm-generic; do
  ln -s "${BUILD_PREFIX}/x86_64-conda-linux-gnu/sysroot/usr/include/${dir}" \
    "pizfix/os-include/${dir}"
done
./build_yolomusl.sh
./build_runtime.sh
./build_usermusl.sh
./build_cxx.sh

# Install, mirroring upstream's package-build.sh layout: the clang driver
# locates the Fil-C runtime at <real-path-of-clang>/../../pizfix.
DEST="${PREFIX}/lib/fil-c"
mkdir -p "${DEST}/build/bin"
cp build/bin/clang-20 "${DEST}/build/bin/"
"${STRIP}" "${DEST}/build/bin/clang-20"
(cd "${DEST}/build/bin" && ln -s clang-20 clang && ln -s clang-20 clang++ &&
  ln -s clang-20 filcc && ln -s clang-20 fil++ && ln -s clang-20 filcpp)

mkdir -p "${DEST}/build/include/x86_64-unknown-linux-gnu"
cp -R build/include/c++ "${DEST}/build/include/"
cp -R build/include/x86_64-unknown-linux-gnu/c++ "${DEST}/build/include/x86_64-unknown-linux-gnu/"
mkdir -p "${DEST}/build/lib/clang/20"
cp -R build/lib/clang/20/include "${DEST}/build/lib/clang/20/"

cp -a pizfix "${DEST}/"
rm -rf "${DEST}/pizfix/yolo-include" "${DEST}/pizfix/os-include"
cp README.md "${DEST}/"

# Upstream's setup.sh sets these rpaths to absolute paths of the unpack
# location; use $ORIGIN-relative rpaths instead so the tree is relocatable.
patchelf --set-rpath '$ORIGIN' "${DEST}/pizfix/lib/libc.so"
patchelf --set-rpath '$ORIGIN' "${DEST}/pizfix/lib/libpizlo.so"
patchelf --set-rpath '$ORIGIN' "${DEST}/pizfix/lib/libc++.so.1.0"
patchelf --set-rpath '$ORIGIN' "${DEST}/pizfix/lib/libc++abi.so.1.0"
patchelf --set-rpath '$ORIGIN/../lib' "${DEST}/pizfix/lib_test/libpizlo.so"
patchelf --set-rpath '$ORIGIN/../lib' "${DEST}/pizfix/lib_test_gcverify/libpizlo.so"
patchelf --set-rpath '$ORIGIN/../lib' "${DEST}/pizfix/lib_gcverify/libpizlo.so"

# The dynamic loader for Fil-C programs is libyoloc.so itself.
rm -f "${DEST}/pizfix/lib/ld-yolo-x86_64.so"
ln -s libyoloc.so "${DEST}/pizfix/lib/ld-yolo-x86_64.so"

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
