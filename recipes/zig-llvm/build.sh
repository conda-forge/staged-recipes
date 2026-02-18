#!/usr/bin/env bash
# Build LLVM with zig cc for zig-llvmdev package
# This produces LLVM/Clang/LLD shared libraries with libc++ ABI
# compatible with zig-cc-built zigcpp

set -euxo pipefail
IFS=$'\n\t'

if [[ ${BASH_VERSINFO[0]} -lt 5 || (${BASH_VERSINFO[0]} -eq 5 && ${BASH_VERSINFO[1]} -lt 2) ]]; then
  echo "ERROR: This script requires bash 5.2 or later (found ${BASH_VERSION})"
  echo "Attempting to re-exec with conda bash..."
  if [[ -x "${BUILD_PREFIX}/bin/bash" ]]; then
    exec "${BUILD_PREFIX}/bin/bash" "$0" "$@"
  elif [[ -x "${BUILD_PREFIX}/Library/bin/bash" ]]; then
    exec "${BUILD_PREFIX}/Library/bin/bash" "$0" "$@"
  else
    echo "ERROR: Could not find conda bash at ${BUILD_PREFIX}/bin/bash"
    exit 1
  fi
fi

source "${RECIPE_DIR}/build-functions.sh"

echo "=== Building zig-llvmdev with zig cc ==="
echo "  LLVM source: ${SRC_DIR}/llvm-source"
echo "  Target: ${target_platform}"

# Get bootstrap zig - install via mamba to break cycle
# zig-llvmdev needs zig cc, but we're building zig, so use previous version
BOOTSTRAP_ZIG="${BUILD_PREFIX}/bin/zig"
if [[ ! -x "${BOOTSTRAP_ZIG}" ]]; then
    echo "ERROR: Bootstrap zig not found after install attempt"
    exit 1
fi
echo "  Bootstrap zig: ${BOOTSTRAP_ZIG} ($(${BOOTSTRAP_ZIG} version))"

# Cross-compilation detection and setup
# CONDA_BUILD_CROSS_COMPILATION is set by conda-build when build_platform != target_platform
CMAKE_CROSS_FLAGS=()
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "1" ]]; then
    echo "=== Cross-compilation detected ==="
    echo "  Build platform: ${build_platform}"
    echo "  Target platform: ${target_platform}"

    # Determine target system name for cmake
    case "${target_platform}" in
        linux-*)
            CMAKE_SYSTEM_NAME="Linux" ;;
        osx-*)
            CMAKE_SYSTEM_NAME="Darwin" ;;
        win-*)
            CMAKE_SYSTEM_NAME="Windows" ;;
        *)
            echo "ERROR: Unknown target platform family: ${target_platform}"
            exit 1 ;;
    esac

    # Tablegen tools run on the BUILD host, not target
    # These are provided by llvmdev/clangdev build dependencies
    LLVM_TBLGEN="${BUILD_PREFIX}/bin/llvm-tblgen"
    CLANG_TBLGEN="${BUILD_PREFIX}/bin/clang-tblgen"

    if [[ ! -x "${LLVM_TBLGEN}" ]]; then
        echo "ERROR: llvm-tblgen not found at ${LLVM_TBLGEN}"
        echo "  Cross-compilation requires llvmdev as a build dependency"
        exit 1
    fi
    if [[ ! -x "${CLANG_TBLGEN}" ]]; then
        echo "ERROR: clang-tblgen not found at ${CLANG_TBLGEN}"
        echo "  Cross-compilation requires clangdev as a build dependency"
        exit 1
    fi

    CMAKE_CROSS_FLAGS=(
        -DCMAKE_CROSSCOMPILING=True
        -DCMAKE_SYSTEM_NAME="${CMAKE_SYSTEM_NAME}"
        -DLLVM_TABLEGEN="${LLVM_TBLGEN}"
        -DCLANG_TABLEGEN="${CLANG_TBLGEN}"
        -DLLVM_DEFAULT_TARGET_TRIPLE="${ZIG_TARGET}"
        -DLLVM_HOST_TRIPLE="${ZIG_TARGET}"
    )

    echo "  CMAKE_SYSTEM_NAME: ${CMAKE_SYSTEM_NAME}"
    echo "  LLVM_TABLEGEN: ${LLVM_TBLGEN}"
    echo "  CLANG_TABLEGEN: ${CLANG_TBLGEN}"
    echo "  ZIG_TARGET: ${ZIG_TARGET}"
fi

# Setup zig as C/C++ compiler (works for both native and cross-compilation)
setup_zig_cc "${BOOTSTRAP_ZIG}" "${ZIG_TARGET}" "baseline"

# Build directories
# Install to lib/zig-llvm to avoid conflicts with conda-forge llvmdev
LLVM_SRC="${SRC_DIR}/llvm"
LLVM_BUILD="${SRC_DIR}/conda-llvm-build"
LLVM_INSTALL="${PREFIX}/lib/zig-llvm"

mkdir -p "${LLVM_BUILD}"

_CLANG=(
    -DCLANG_BUILD_TOOLS=OFF
    -DCLANG_ENABLE_ARCMT=OFF
    -DCLANG_ENABLE_OBJC_REWRITER=ON
    -DCLANG_ENABLE_STATIC_ANALYZER=OFF
    -DCLANG_INCLUDE_DOCS=OFF
    -DCLANG_INCLUDE_TESTS=OFF
    -DCLANG_LINK_CLANG_DYLIB=ON
    -DCLANG_TOOL_CLANG_IMPORT_TEST_BUILD=OFF
    -DCLANG_TOOL_CLANG_LINKER_WRAPPER_BUILD=OFF
    -DCLANG_TOOL_C_INDEX_TEST_BUILD=OFF
    -DCLANG_TOOL_LIBCLANG_BUILD=OFF
)

_LLVM=(
    -DLLVM_BUILD_LLVM_DYLIB=ON
    -DLLVM_BUILD_TOOLS=OFF
    -DLLVM_BUILD_UTILS=OFF
    -DLLVM_DEFAULT_TARGET_TRIPLE="${ZIG_TARGET}"
    -DLLVM_ENABLE_ASSERTIONS=OFF
    -DLLVM_ENABLE_BACKTRACES=OFF
    -DLLVM_ENABLE_BINDINGS=OFF
    -DLLVM_ENABLE_CRASH_OVERRIDES=OFF
    -DLLVM_ENABLE_LIBEDIT=OFF
    -DLLVM_ENABLE_LIBPFM=OFF
    -DLLVM_ENABLE_LIBXML2=ON
    -DLLVM_ENABLE_OCAMLDOC=OFF
    -DLLVM_ENABLE_PLUGINS=OFF
    -DLLVM_ENABLE_PROJECTS="clang;lld"
    -DLLVM_ENABLE_Z3_SOLVER=OFF
    -DLLVM_ENABLE_ZLIB=ON
    -DLLVM_ENABLE_ZSTD=ON
    -DLLVM_HAS_LOGF128=OFF
    -DLLVM_INCLUDE_BENCHMARKS=OFF
    -DLLVM_INCLUDE_DOCS=OFF
    -DLLVM_INCLUDE_EXAMPLES=OFF
    -DLLVM_INCLUDE_TESTS=OFF
    -DLLVM_INCLUDE_UTILS=OFF
    -DLLVM_INSTALL_TOOLCHAIN_ONLY=OFF
    -DLLVM_LINK_LLVM_DYLIB=ON
    -DLLVM_TARGETS_TO_BUILD="X86;AArch64;ARM;PowerPC;RISCV"
    # -DLLVM_TARGETS_TO_BUILD="X86;AArch64;ARM;PowerPC;RISCV;WebAssembly;SystemZ"
    -DLLVM_TOOL_LLVM_EXEGESIS_BUILD=OFF
    -DLLVM_TOOL_LLVM_LTO2_BUILD=OFF
    -DLLVM_TOOL_LLVM_LTO_BUILD=OFF
    -DLLVM_TOOL_LTO_BUILD=OFF
)

echo "=== Configuring LLVM ==="
echo "  Install prefix: ${LLVM_INSTALL} (separate from conda-forge llvmdev)"
_CMAKE=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX="${LLVM_INSTALL}"
    -DCMAKE_PREFIX_PATH="${PREFIX};${BUILD_PREFIX}"
    -DCMAKE_LINK_DEPENDS_USE_LINKER=OFF
    
    -DCMAKE_AR="${ZIG_AR}"
    -DCMAKE_C_COMPILER="${ZIG_CC}"
    -DCMAKE_CXX_COMPILER="${ZIG_CXX}"
    -DCMAKE_ASM_COMPILER="${ZIG_ASM}"
    -DCMAKE_RANLIB="${ZIG_RANLIB}"
    -DCMAKE_RC_COMPILER="${ZIG_RC}"
)
cmake -S "${LLVM_SRC}" -B "${LLVM_BUILD}" \
    "${CMAKE_CROSS_FLAGS[@]}" \
    -DHAS_LOGF128=OFF \
    -DLLD_BUILD_TOOLS=OFF \
    "${_CMAKE[@]}" \
    "${_CLANG[@]}" \
    "${_LLVM[@]}" \
    -G Ninja

echo "=== Building LLVM libraries ==="
# LLVM_BUILD_TOOLS=OFF means default target only builds libraries
cmake --build "${LLVM_BUILD}" -j"${CPU_COUNT}"

echo "=== Building llvm-config ==="
# Build llvm-config explicitly (only tool we need)
cmake --build "${LLVM_BUILD}" -j"${CPU_COUNT}" --target llvm-config

echo "=== Installing LLVM ==="
cmake --install "${LLVM_BUILD}"

# Remove static libraries - zig only needs shared libs (saves ~500MB)
echo "=== Removing static libraries ==="
find "${LLVM_INSTALL}/lib" -name "*.a" -type f -delete
echo "  Removed .a files from ${LLVM_INSTALL}/lib"

echo "=== zig-llvm build complete ==="
echo "  Installed to: ${LLVM_INSTALL}"
echo "  llvm-config: ${LLVM_INSTALL}/bin/llvm-config"
ls -la "${LLVM_INSTALL}/lib/"libLLVM* "${LLVM_INSTALL}/lib/"libclang* "${LLVM_INSTALL}/lib/"liblld* 2>/dev/null | head -20 || true

# Create llvm-config wrapper that filters out flags unsupported by zig's linker
# zig build calls llvm-config --ldflags and passes results directly to its linker
# Flags like -Bsymbolic-functions are GNU ld specific and not supported by lld/zig linker
echo "=== Creating llvm-config wrapper to filter unsupported linker flags ==="
mv "${LLVM_INSTALL}/bin/llvm-config" "${LLVM_INSTALL}/bin/llvm-config.real"
cat > "${LLVM_INSTALL}/bin/llvm-config" << 'WRAPPER_EOF'
#!/usr/bin/env bash
# Wrapper for llvm-config that filters out flags unsupported by zig's linker
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REAL_CONFIG="${SCRIPT_DIR}/llvm-config.real"

# Run the real llvm-config
output=$("${REAL_CONFIG}" "$@")

# Filter output for --ldflags and --system-libs which may contain unsupported flags
for arg in "$@"; do
    case "$arg" in
        --ldflags|--system-libs|--libs|--link-static|--link-shared)
            # Filter out GNU ld specific flags that zig's linker doesn't support
            output=$(echo "$output" | sed \
                -e 's/-Wl,-Bsymbolic-functions//g' \
                -e 's/-Bsymbolic-functions//g' \
                -e 's/-Wl,-Bsymbolic//g' \
                -e 's/-Bsymbolic//g' \
                -e 's/-Wl,--disable-new-dtags//g' \
                -e 's/  */ /g' \
                -e 's/^ *//' \
                -e 's/ *$//')
            break
            ;;
    esac
done

echo "$output"
WRAPPER_EOF
chmod +x "${LLVM_INSTALL}/bin/llvm-config"
echo "  Created wrapper: ${LLVM_INSTALL}/bin/llvm-config"

# Create a marker file for zig build to find this LLVM
echo "${LLVM_INSTALL}" > "${PREFIX}/lib/zig-llvm-path.txt"
