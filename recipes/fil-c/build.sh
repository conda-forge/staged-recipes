#!/bin/bash
set -euxo pipefail

# ---- disk reclamation: CI agents have only ~7 GiB total for this build ----
# Sources are fetched/extracted and envs installed by the time this script
# runs: the 2 GiB cached source tarball and the package-cache archives
# (already extracted into the envs) can go. Set FILC_KEEP_CACHES for local
# builds to keep iteration fast.
if [ -z "${FILC_KEEP_CACHES:-}" ]; then
  find "${SRC_DIR}/../../../src_cache" -type f -size +100M -delete 2>/dev/null || true
  find "${SRC_DIR}/../../../pkg_cache" -type f \( -name "*.conda" -o -name "*.tar.bz2" \) -delete 2>/dev/null || true
fi

# The tarball carries benchmark data, LLVM subprojects and ported-project
# sources that the base toolchain build does not need. yolomusl/usermusl
# must stay: they are the Fil-C libc.
rm -rf benchmarkData pizlix optfil bolt clang-tools-extra cross-project-tests \
  flang libclc lldb llvm-libgcc mlir offload openmp polly pstl
for d in projects/*; do
  case "$d" in
    projects/yolomusl | projects/usermusl) ;;
    *) rm -rf "$d" ;;
  esac
done
# Test suites are never built (LLVM_INCLUDE_TESTS=OFF below). The libcxx/
# libcxxabi test dirs and the docs dirs must stay: cmake includes them
# unconditionally.
rm -rf llvm/test llvm/unittests clang/test clang/unittests

# ---- adapt the upstream build to the conda toolchain and CI resources ----
# Release instead of RelWithDebInfo and serialized link jobs: the 7 GiB RAM
# agents cannot link clang with debug info. No lld: GNU ld links fine and
# keeps the clang+lld packages out of the disk budget.
sed -i \
  -e 's/-DCMAKE_BUILD_TYPE=RelWithDebInfo/-DCMAKE_BUILD_TYPE=Release -DLLVM_PARALLEL_LINK_JOBS=1 -DLLVM_INCLUDE_TESTS=OFF/' \
  -e 's/-DLLVM_ENABLE_LLD=ON//' \
  configure_llvm.sh

# libpas and yolounwind default to a host clang; building with g++/gcc is
# supported upstream (see the commented block in libpas/Makefile) and saves
# ~1 GiB of build env.
GCC_INTERNAL_INCLUDE="$(${CC} -print-file-name=include)"
# g++ is required (not gcc): the libpas C sources use compound-literal
# static initializers that C-mode gcc rejects. -fpermissive covers the one
# C-ism that is not valid C++, the -Wno flags silence gcc false positives
# (atomic ops on GC object headers) that upstream's clang build never sees,
# and -Werror goes so warning noise cannot fail the build.
sed -i "s|^HOST_CLANG_EXTRA_FLAGS = .*|HOST_CLANG_EXTRA_FLAGS = -Wno-expansion-to-defined -Wno-pragmas -Wno-address-of-packed-member -Wno-missing-field-initializers -isystem ${GCC_INTERNAL_INCLUDE} -Wno-stringop-overflow -Wno-array-bounds -Wno-free-nonheap-object -fpermissive|" libpas/Makefile
sed -i "s/ -Werror//g" libpas/Makefile libpas/common.mk
export HOST_CLANG="${CXX}"
sed -i "s|^\tclang |\t\$(CC) |" yolounwind/Makefile

# The freshly built fil-c clang invokes plain `ld` when linking usermusl and
# the runtimes, and several upstream scripts use plain `ar`; conda binutils
# only puts triple-prefixed names on PATH.
for tool in ld ar ranlib nm strip objcopy as; do
  if [ ! -e "${BUILD_PREFIX}/bin/${tool}" ]; then
    ln -s "${BUILD_PREFIX}/x86_64-conda-linux-gnu/bin/${tool}" "${BUILD_PREFIX}/bin/${tool}"
  fi
done

# Scale ninja parallelism to the machine, capped by available RAM (large
# LLVM translation units need ~2 GiB each); CI agents resolve to -j 2.
MEM_GB=$(awk '/MemTotal/ {print int($2/1048576)}' /proc/meminfo)
JOBS=${CPU_COUNT:-2}
if ((JOBS > MEM_GB / 2)); then JOBS=$((MEM_GB / 2)); fi
((JOBS >= 1)) || JOBS=1
# build_clang.sh/build_cxx.sh/build_compiler_rt.sh source this hook
cat > clang-build-overrides.sh <<EOF
NINJAFLAGS="-j ${JOBS}"
NINJARUNTIMEFLAGS="-j ${JOBS}"
EOF

# ---- the steps of upstream's build_base.sh ----
# build_os_include.sh is replaced: it symlinks /usr/include kernel headers,
# which do not exist here; use the conda sysroot ones.
./build_compiler_rt.sh
./build_yolounwind.sh
./configure_llvm.sh
./build_clang.sh
# from the host env's kernel-headers_linux-64: the gcc sysroot's own kernel
# headers are too old for the Fil-C runtime (it needs e.g. linux/landlock.h)
mkdir -p pizfix/os-include
for dir in linux asm asm-generic; do
  ln -s "${PREFIX}/x86_64-conda-linux-gnu/sysroot/usr/include/${dir}" \
    "pizfix/os-include/${dir}"
done
./build_yolomusl.sh
./build_runtime.sh
./build_usermusl.sh
./build_cxx.sh

# ---- install, mirroring upstream's package-build.sh layout ----
# The clang driver locates the Fil-C runtime at <real-path-of-clang>/../../pizfix.
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
