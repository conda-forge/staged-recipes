#!/bin/bash
set -euxo pipefail

# ---------------------------------------------------------------------------
# 1. Build LLVM/Clang + libc++ from the exact development commit MrDocs pins.
#
# MrDocs' own CMake (mrdocs/src/setup-llvm.cmake) refuses any "system" LLVM
# and requires an LLVM_ROOT that contains libc++ headers at
# <LLVM_ROOT>/include/c++/v1 -- i.e. an LLVM built in-tree with the libcxx
# runtime enabled. It also pins an unreleased llvm-project commit rather than
# a tagged release, so conda-forge's llvmdev/clangdev packages (which track
# releases) are not used here. Options mirror the "release-unix" CMake preset
# MrDocs' own bootstrap tool uses (utils/bootstrap/patches/llvm/llvm/CMakePresets.json).
# ---------------------------------------------------------------------------
LLVM_INSTALL="${SRC_DIR}/llvm-install"

# conda-forge's gxx_linux-64 activation exports CXXFLAGS/CFLAGS with
# GCC-specific flags (notably -fno-merge-constants). Those are fine for the
# initial GCC-built stage of LLVM/Clang, but LLVM_ENABLE_RUNTIMES triggers a
# second, self-hosted sub-build (libcxx/libcxxabi/libunwind) configured with
# the *just-built* Clang, which inherits these same env vars as a subprocess.
# Clang doesn't understand -fno-merge-constants and emits "optimization flag
# ... is not supported", a message that matches CMake's generic FAIL_REGEX
# used by every check_cxx_compiler_flag() test -- silently failing unrelated
# checks (e.g. CXX_SUPPORTS_FNO_EXCEPTIONS_FLAG) and aborting libunwind's
# configure with a fatal error. Unset them for this step; the final mrdocs
# binary (built with GCC in step 3 below) still gets normal conda-forge
# hardening flags.
unset CFLAGS CXXFLAGS

cmake -S "${SRC_DIR}/llvm-project/llvm" -B "${SRC_DIR}/llvm-build" -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${LLVM_INSTALL}" \
    -DLLVM_ENABLE_PROJECTS=clang \
    -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind" \
    -DLLVM_TARGETS_TO_BUILD=Native \
    -DLLVM_ENABLE_ZLIB=OFF \
    -DLLVM_ENABLE_ZSTD=OFF \
    -DLLVM_ENABLE_LIBXML2=OFF \
    -DLLVM_ENABLE_BACKTRACES=OFF \
    -DLLVM_ENABLE_TERMINFO=OFF \
    -DLLVM_ENABLE_RTTI=ON \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DLLVM_ENABLE_BINDINGS=OFF \
    -DLLVM_ENABLE_OCAMLDOC=OFF \
    -DLLVM_INCLUDE_BENCHMARKS=OFF \
    -DLLVM_INCLUDE_DOCS=OFF \
    -DLLVM_INCLUDE_EXAMPLES=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_BUILD_TESTS=OFF \
    -DLLVM_BUILD_DOCS=OFF \
    -DLLVM_BUILD_EXAMPLES=OFF \
    -DLLVM_BUILD_LLVM_C_DYLIB=OFF \
    -DCLANG_ENABLE_STATIC_ANALYZER=OFF \
    -DCLANG_ENABLE_ARCMT=OFF \
    -DCLANG_ENABLE_FORMAT=OFF \
    -DCLANG_INCLUDE_TESTS=OFF \
    -DCLANG_INCLUDE_DOCS=OFF \
    -DCLANG_BUILD_EXAMPLES=OFF \
    -DLIBCXX_ENABLE_SHARED=OFF \
    -DLIBCXX_ENABLE_STATIC=ON \
    -DLIBCXX_INCLUDE_TESTS=OFF \
    -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
    -DLIBCXXABI_USE_LLVM_UNWINDER=ON

# Some files outside lib/Support (e.g. lib/MC/DXContainerInfo.cpp) #include
# "llvm/Support/VCSRevision.h" without CMake actually wiring a target
# dependency on the custom command that generates it. With enough parallel
# jobs the file happens to exist by the time it's needed (this recipe's
# author didn't hit it locally on a high core count machine), but on
# lower-parallelism CI runners ninja can reach one of those consumers before
# the generator has run at all, failing with "No such file or directory".
# Since our source is a tarball snapshot (no .git), the generated header
# would contain no real VCS info anyway -- pre-create it empty so the
# #include always resolves, regardless of ninja's scheduling order.
mkdir -p "${SRC_DIR}/llvm-build/include/llvm/Support"
touch "${SRC_DIR}/llvm-build/include/llvm/Support/VCSRevision.h"

cmake --build "${SRC_DIR}/llvm-build" --target install -j"${CPU_COUNT}"

# Drop the LLVM build tree once installed; it is much larger than the final
# mrdocs package and is only needed as a build-time dependency.
rm -rf "${SRC_DIR}/llvm-build"

# ---------------------------------------------------------------------------
# 2. Wire the conda-forge `lua` host package into a CMake package config,
# since MrDocs requires `find_package(Lua CONFIG REQUIRED)` and neither
# upstream Lua nor conda-forge's package provide one.
# ---------------------------------------------------------------------------
cmake -S "${SRC_DIR}/lua-shim" -B "${SRC_DIR}/lua-shim-build" -GNinja \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_PREFIX_PATH="${PREFIX}"
cmake --build "${SRC_DIR}/lua-shim-build" --target install

# ---------------------------------------------------------------------------
# 3. Configure, build and install MrDocs itself.
# ---------------------------------------------------------------------------
cmake -S "${SRC_DIR}/mrdocs" -B "${SRC_DIR}/mrdocs-build" -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DLLVM_ROOT="${LLVM_INSTALL}" \
    -DLua_ROOT="${PREFIX}" \
    -Djerryscript_ROOT="${PREFIX}" \
    -DMRDOCS_REQUIRE_GIT=OFF \
    -DMRDOCS_BUILD_TESTS=OFF \
    -DMRDOCS_BUILD_EXAMPLES=OFF \
    -DMRDOCS_BUILD_DOCS=OFF \
    -DMRDOCS_GENERATE_REFERENCE=OFF

cmake --build "${SRC_DIR}/mrdocs-build" -j"${CPU_COUNT}"
cmake --install "${SRC_DIR}/mrdocs-build"
