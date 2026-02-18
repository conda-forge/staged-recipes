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

# === BUILD CACHE ===
# For faster iteration on packaging/tests, cache built artifacts in recipe folder
# Cache location: ${RECIPE_DIR}/cache/zig-llvm/
#
# To populate cache from a successful build:
#   cp -r output/bld/rattler-build_zig-llvm_*/host_env_*/lib/zig-llvm recipes/zig-llvm/cache/
#   cp output/bld/rattler-build_zig-llvm_*/host_env_*/lib/zig-llvm-path.txt recipes/zig-llvm/cache/
#
# Set ZIG_LLVM_FORCE_BUILD=1 to ignore cache and rebuild

CACHE_DIR="${RECIPE_DIR}/cache"

# Check if cache has required files (use ls for glob expansion)
CACHE_HAS_LLVM=$(ls "${CACHE_DIR}/lib/"libLLVM*.so* 2>/dev/null | head -1)

if [[ "${ZIG_LLVM_FORCE_BUILD:-0}" != "1" ]] && [[ -d "${CACHE_DIR}" ]] && \
   [[ -x "${CACHE_DIR}/bin/llvm-config" ]] && \
   [[ -n "${CACHE_HAS_LLVM}" ]]; then
    echo "=== USING CACHED LLVM BUILD ==="
    echo "  Cache found at: ${CACHE_DIR}"
    echo "  llvm-config version: $("${CACHE_DIR}/bin/llvm-config" --version)"
    echo ""
    echo "  Copying cache to: ${LLVM_INSTALL}"

    mkdir -p "${PREFIX}/lib"
    cp -a "${CACHE_DIR}" "${LLVM_INSTALL}"

    # Create marker file
    echo "${LLVM_INSTALL}" > "${PREFIX}/lib/zig-llvm-path.txt"

    echo "  Cache installed successfully!"
    echo "  Set ZIG_LLVM_FORCE_BUILD=1 to rebuild from source"
    ls -la "${LLVM_INSTALL}/lib/"*.so* | head -10
    exit 0
fi

if [[ "${ZIG_LLVM_FORCE_BUILD:-0}" == "1" ]]; then
    echo "=== FORCING LLVM BUILD (ZIG_LLVM_FORCE_BUILD=1) ==="
elif [[ -d "${CACHE_DIR}" ]]; then
    echo "=== Cache found but incomplete, rebuilding ==="
else
    echo "=== No cache found, building from source ==="
    echo "  To speed up future builds, populate cache after successful build:"
    echo "    mkdir -p ${RECIPE_DIR}/cache"
    echo "    cp -r \${PREFIX}/lib/zig-llvm ${RECIPE_DIR}/cache/"
fi

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
    -DLLVM_BUILD_TOOLS=ON
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
    # Disable all tools except llvm-config (saves significant build time)
    -DLLVM_TOOL_BUGPOINT_BUILD=OFF
    -DLLVM_TOOL_DSYMUTIL_BUILD=OFF
    -DLLVM_TOOL_GOLD_BUILD=OFF
    -DLLVM_TOOL_LLC_BUILD=OFF
    -DLLVM_TOOL_LLI_BUILD=OFF
    -DLLVM_TOOL_LLVM_AR_BUILD=OFF
    -DLLVM_TOOL_LLVM_AS_BUILD=OFF
    -DLLVM_TOOL_LLVM_BCANALYZER_BUILD=OFF
    -DLLVM_TOOL_LLVM_CAT_BUILD=OFF
    -DLLVM_TOOL_LLVM_CFI_VERIFY_BUILD=OFF
    -DLLVM_TOOL_LLVM_COV_BUILD=OFF
    -DLLVM_TOOL_LLVM_CVTRES_BUILD=OFF
    -DLLVM_TOOL_LLVM_CXXDUMP_BUILD=OFF
    -DLLVM_TOOL_LLVM_CXXFILT_BUILD=OFF
    -DLLVM_TOOL_LLVM_CXXMAP_BUILD=OFF
    -DLLVM_TOOL_LLVM_DIFF_BUILD=OFF
    -DLLVM_TOOL_LLVM_DIS_BUILD=OFF
    -DLLVM_TOOL_LLVM_DLLTOOL_BUILD=OFF
    -DLLVM_TOOL_LLVM_DWARFDUMP_BUILD=OFF
    -DLLVM_TOOL_LLVM_DWARFUTIL_BUILD=OFF
    -DLLVM_TOOL_LLVM_DWP_BUILD=OFF
    -DLLVM_TOOL_LLVM_EXEGESIS_BUILD=OFF
    -DLLVM_TOOL_LLVM_EXTRACT_BUILD=OFF
    -DLLVM_TOOL_LLVM_GSYMUTIL_BUILD=OFF
    -DLLVM_TOOL_LLVM_IFS_BUILD=OFF
    -DLLVM_TOOL_LLVM_JITLINK_BUILD=OFF
    -DLLVM_TOOL_LLVM_LINK_BUILD=OFF
    -DLLVM_TOOL_LLVM_LIPO_BUILD=OFF
    -DLLVM_TOOL_LLVM_LTO2_BUILD=OFF
    -DLLVM_TOOL_LLVM_LTO_BUILD=OFF
    -DLLVM_TOOL_LLVM_MC_BUILD=OFF
    -DLLVM_TOOL_LLVM_MCA_BUILD=OFF
    -DLLVM_TOOL_LLVM_ML_BUILD=OFF
    -DLLVM_TOOL_LLVM_MODEXTRACT_BUILD=OFF
    -DLLVM_TOOL_LLVM_MT_BUILD=OFF
    -DLLVM_TOOL_LLVM_NM_BUILD=OFF
    -DLLVM_TOOL_LLVM_OBJCOPY_BUILD=OFF
    -DLLVM_TOOL_LLVM_OBJDUMP_BUILD=OFF
    -DLLVM_TOOL_LLVM_OPT_REPORT_BUILD=OFF
    -DLLVM_TOOL_LLVM_PDBUTIL_BUILD=OFF
    -DLLVM_TOOL_LLVM_PROFDATA_BUILD=OFF
    -DLLVM_TOOL_LLVM_PROFGEN_BUILD=OFF
    -DLLVM_TOOL_LLVM_RC_BUILD=OFF
    -DLLVM_TOOL_LLVM_READOBJ_BUILD=OFF
    -DLLVM_TOOL_LLVM_REDUCE_BUILD=OFF
    -DLLVM_TOOL_LLVM_REMARK_SIZE_DIFF_BUILD=OFF
    -DLLVM_TOOL_LLVM_RTDYLD_BUILD=OFF
    -DLLVM_TOOL_LLVM_SIM_BUILD=OFF
    -DLLVM_TOOL_LLVM_SIZE_BUILD=OFF
    -DLLVM_TOOL_LLVM_SPLIT_BUILD=OFF
    -DLLVM_TOOL_LLVM_STRESS_BUILD=OFF
    -DLLVM_TOOL_LLVM_STRINGS_BUILD=OFF
    -DLLVM_TOOL_LLVM_SYMBOLIZER_BUILD=OFF
    -DLLVM_TOOL_LLVM_TAPI_DIFF_BUILD=OFF
    -DLLVM_TOOL_LLVM_TLI_CHECKER_BUILD=OFF
    -DLLVM_TOOL_LLVM_UNDNAME_BUILD=OFF
    -DLLVM_TOOL_LLVM_XRAY_BUILD=OFF
    -DLLVM_TOOL_LTO_BUILD=OFF
    -DLLVM_TOOL_OBJ2YAML_BUILD=OFF
    -DLLVM_TOOL_OPT_BUILD=OFF
    -DLLVM_TOOL_REMARKS_SHLIB_BUILD=OFF
    -DLLVM_TOOL_SANCOV_BUILD=OFF
    -DLLVM_TOOL_SANSTATS_BUILD=OFF
    -DLLVM_TOOL_SPLIT_FILE_BUILD=OFF
    -DLLVM_TOOL_VERIFY_USELISTORDER_BUILD=OFF
    -DLLVM_TOOL_VFABI_DEMANGLE_FUZZER_BUILD=OFF
    -DLLVM_TOOL_XCODE_TOOLCHAIN_BUILD=OFF
    -DLLVM_TOOL_YAML2OBJ_BUILD=OFF
    # Keep llvm-config (default ON when LLVM_BUILD_TOOLS=ON)
    -DLLVM_TOOL_LLVM_CONFIG_BUILD=ON
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

echo "=== Building LLVM ==="
cmake --build "${LLVM_BUILD}" -j"${CPU_COUNT}"

echo "=== Installing LLVM ==="
cmake --install "${LLVM_BUILD}"

# Remove static libraries - zig only needs shared libs (saves ~500MB)
echo "=== Removing static libraries ==="
find "${LLVM_INSTALL}/lib" -name "*.a" -type f -delete
echo "  Removed .a files from ${LLVM_INSTALL}/lib"

# Remove all tools except llvm-config (other tools come from conda-forge llvm-tools)
# Many LLVM tools are symlinks, so delete both files and symlinks
echo "=== Removing tools except llvm-config ==="
find "${LLVM_INSTALL}/bin" \( -type f -o -type l \) ! -name "llvm-config*" -delete
ls "${LLVM_INSTALL}/bin/"
echo "  Kept only llvm-config in ${LLVM_INSTALL}/bin"

# Remove share/ directory (clang-format helpers, cmake modules we don't need)
echo "=== Removing share/ directory ==="
rm -rf "${LLVM_INSTALL}/share"
echo "  Removed ${LLVM_INSTALL}/share"

# Remove C API headers (zig uses C++ API, not C bindings)
echo "=== Removing C API headers ==="
rm -rf "${LLVM_INSTALL}/include/llvm-c"
rm -rf "${LLVM_INSTALL}/include/clang-c"
echo "  Removed llvm-c/ and clang-c/ headers"

# Remove CMake modules (zig uses llvm-config, not find_package)
echo "=== Removing CMake modules ==="
rm -rf "${LLVM_INSTALL}/lib/cmake"
echo "  Removed lib/cmake/"

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
