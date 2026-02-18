# ZIG CC COMPILER WRAPPERS (Primary build method - zig as C/C++ compiler)

# === Setup zig as C/C++ compiler ===
# Creates wrapper scripts for CMake that invoke zig cc/c++/ar/ranlib
# This eliminates the need for GCC workarounds since zig bundles its own libc
#
# Args:
#   $1 - zig binary path (required)
#   $2 - target triple (default: native)
#   $3 - mcpu (default: baseline)
#
# Exports: ZIG_CC, ZIG_CXX, ZIG_ASM, ZIG_AR, ZIG_RANLIB, ZIG_RC
#
# Usage:
#   setup_zig_cc "${BOOTSTRAP_ZIG}" "x86_64-linux-gnu" "baseline"
#   cmake ... -DCMAKE_C_COMPILER="${ZIG_CC}" ...
#
setup_zig_cc() {
    local zig="$1"
    local target="${2:-native}"
    local mcpu="${3:-baseline}"
    local wrapper_dir="${SRC_DIR}/zig-cc-wrappers"

    if [[ -z "${zig}" ]] || [[ ! -x "${zig}" ]]; then
        echo "ERROR: setup_zig_cc requires valid zig binary path" >&2
        return 1
    fi

    mkdir -p "${wrapper_dir}"

    # zig-cc wrapper - filters out GCC-specific flags that zig doesn't support
    cat > "${wrapper_dir}/zig-cc" << 'WRAPPER_EOF'
#!/usr/bin/env bash
# Filter out flags that zig cc doesn't support
# This wrapper processes arguments and removes GNU ld-specific flags that
# zig's internal lld-based linker doesn't support

args=()
is_linking=0
i=0
argv=("$@")
argc=${#argv[@]}

while [[ $i -lt $argc ]]; do
    arg="${argv[$i]}"

    case "$arg" in
        # Detect if this is a link step (has -o but no -c)
        -o) is_linking=1; args+=("$arg") ;;
        -c) is_linking=0; args+=("$arg") ;;

        # Handle -Xlinker <arg> pairs - check if next arg should be filtered
        -Xlinker)
            # Look at next argument
            next_i=$((i + 1))
            if [[ $next_i -lt $argc ]]; then
                next_arg="${argv[$next_i]}"
                case "$next_arg" in
                    # These are flags that zig's linker doesn't support
                    -Bsymbolic-functions|-Bsymbolic|--color-diagnostics)
                        # Skip both -Xlinker and its argument
                        i=$next_i
                        ;;
                    *)
                        # Pass through -Xlinker and its argument
                        args+=("$arg" "$next_arg")
                        i=$next_i
                        ;;
                esac
            fi
            ;;

        # Unsupported -Wl, flags (zig uses lld which doesn't support these GNU ld flags)
        -Wl,-rpath-link|-Wl,-rpath-link,*|-Wl,--disable-new-dtags)
            ;; # skip
        -Wl,--allow-shlib-undefined|-Wl,--no-allow-shlib-undefined)
            ;; # skip
        -Wl,-Bsymbolic-functions|-Wl,-Bsymbolic)
            ;; # skip
        -Wl,--color-diagnostics)
            ;; # skip - zig doesn't support this
        -Wl,-soname|-Wl,-soname,*)
            ;; # skip - zig handles soname differently
        -Wl,--version-script|-Wl,--version-script,*)
            ;; # skip - version scripts not supported
        -Wl,-z,defs|-Wl,-z,nodelete|-Wl,-z,*)
            ;; # skip - -z flags not all supported
        -Wl,--as-needed|-Wl,--no-as-needed)
            ;; # skip
        -Wl,-O*)
            ;; # skip - linker optimization flags
        -Wl,--gc-sections|-Wl,--no-gc-sections)
            ;; # skip
        -Wl,--build-id|-Wl,--build-id=*)
            ;; # skip

        # Bare linker flags (without -Wl, prefix)
        -Bsymbolic-functions|-Bsymbolic)
            ;; # skip

        # GCC-specific optimization flags
        -march=*|-mtune=*|-ftree-vectorize)
            ;; # skip

        # Stack protector handled differently by zig
        -fstack-protector-strong|-fstack-protector|-fno-plt)
            ;; # skip

        # Debug prefix maps - zig handles differently
        -fdebug-prefix-map=*)
            ;; # skip

        *)
            args+=("$arg")
            ;;
    esac

    ((i++))
done

# Add libstdc++ when linking (LLVM libs need it)
if [[ $is_linking -eq 1 ]]; then
    args+=("-lstdc++")
fi
WRAPPER_EOF
    echo "exec \"${zig}\" cc -target ${target} -mcpu=${mcpu} \"\${args[@]}\"" >> "${wrapper_dir}/zig-cc"
    chmod +x "${wrapper_dir}/zig-cc"

    # zig-c++ wrapper - same filtering as zig-cc, always links libstdc++ for C++
    cat > "${wrapper_dir}/zig-cxx" << 'WRAPPER_EOF'
#!/usr/bin/env bash
# Filter out flags that zig c++ doesn't support
# This wrapper processes arguments and removes GNU ld-specific flags that
# zig's internal lld-based linker doesn't support

args=()
is_linking=0
i=0
argv=("$@")
argc=${#argv[@]}

while [[ $i -lt $argc ]]; do
    arg="${argv[$i]}"

    case "$arg" in
        # Detect if this is a link step (has -o but no -c)
        -o) is_linking=1; args+=("$arg") ;;
        -c) is_linking=0; args+=("$arg") ;;

        # Handle -Xlinker <arg> pairs - check if next arg should be filtered
        -Xlinker)
            # Look at next argument
            next_i=$((i + 1))
            if [[ $next_i -lt $argc ]]; then
                next_arg="${argv[$next_i]}"
                case "$next_arg" in
                    # These are flags that zig's linker doesn't support
                    -Bsymbolic-functions|-Bsymbolic|--color-diagnostics)
                        # Skip both -Xlinker and its argument
                        i=$next_i
                        ;;
                    *)
                        # Pass through -Xlinker and its argument
                        args+=("$arg" "$next_arg")
                        i=$next_i
                        ;;
                esac
            fi
            ;;

        # Unsupported -Wl, flags (zig uses lld which doesn't support these GNU ld flags)
        -Wl,-rpath-link|-Wl,-rpath-link,*|-Wl,--disable-new-dtags)
            ;; # skip
        -Wl,--allow-shlib-undefined|-Wl,--no-allow-shlib-undefined)
            ;; # skip
        -Wl,-Bsymbolic-functions|-Wl,-Bsymbolic)
            ;; # skip
        -Wl,--color-diagnostics)
            ;; # skip - zig doesn't support this
        -Wl,-soname|-Wl,-soname,*)
            ;; # skip - zig handles soname differently
        -Wl,--version-script|-Wl,--version-script,*)
            ;; # skip - version scripts not supported
        -Wl,-z,defs|-Wl,-z,nodelete|-Wl,-z,*)
            ;; # skip - -z flags not all supported
        -Wl,--as-needed|-Wl,--no-as-needed)
            ;; # skip
        -Wl,-O*)
            ;; # skip - linker optimization flags
        -Wl,--gc-sections|-Wl,--no-gc-sections)
            ;; # skip
        -Wl,--build-id|-Wl,--build-id=*)
            ;; # skip

        # Bare linker flags (without -Wl, prefix)
        -Bsymbolic-functions|-Bsymbolic)
            ;; # skip

        # GCC-specific optimization flags
        -march=*|-mtune=*|-ftree-vectorize)
            ;; # skip

        # Stack protector handled differently by zig
        -fstack-protector-strong|-fstack-protector|-fno-plt)
            ;; # skip

        # Debug prefix maps - zig handles differently
        -fdebug-prefix-map=*)
            ;; # skip

        *)
            args+=("$arg")
            ;;
    esac

    ((i++))
done

# Add libstdc++ when linking (LLVM libs need it)
if [[ $is_linking -eq 1 ]]; then
    args+=("-lstdc++")
fi
WRAPPER_EOF
    echo "exec \"${zig}\" c++ -target ${target} -mcpu=${mcpu} \"\${args[@]}\"" >> "${wrapper_dir}/zig-cxx"
    chmod +x "${wrapper_dir}/zig-cxx"

    # zig-ar wrapper
    cat > "${wrapper_dir}/zig-ar" << EOF
#!/usr/bin/env bash
exec "${zig}" ar "\$@"
EOF
    chmod +x "${wrapper_dir}/zig-ar"

    # zig-ranlib wrapper
    cat > "${wrapper_dir}/zig-ranlib" << EOF
#!/usr/bin/env bash
exec "${zig}" ranlib "\$@"
EOF
    chmod +x "${wrapper_dir}/zig-ranlib"

    # zig-asm wrapper (uses zig cc for assembly)
    cat > "${wrapper_dir}/zig-asm" << EOF
#!/usr/bin/env bash
exec "${zig}" cc "\$@"
EOF
    chmod +x "${wrapper_dir}/zig-asm"

    # zig-rc wrapper (Windows resource compiler)
    cat > "${wrapper_dir}/zig-rc" << EOF
#!/usr/bin/env bash
exec "${zig}" rc "\$@"
EOF
    chmod +x "${wrapper_dir}/zig-rc"

    export ZIG_AR="${wrapper_dir}/zig-ar"
    export ZIG_ASM="${wrapper_dir}/zig-asm"
    export ZIG_CC="${wrapper_dir}/zig-cc"
    export ZIG_CXX="${wrapper_dir}/zig-cxx"
    export ZIG_RANLIB="${wrapper_dir}/zig-ranlib"
    export ZIG_RC="${wrapper_dir}/zig-rc"

    # Clear conda's compiler flags - zig handles optimization internally
    # These contain GCC-specific flags that break zig cc
    unset CFLAGS CXXFLAGS LDFLAGS CPPFLAGS
    export CFLAGS="" CXXFLAGS="" LDFLAGS="" CPPFLAGS=""

    echo "=== setup_zig_cc: Created zig compiler wrappers ==="
    echo "  ZIG_CC:     ${ZIG_CC}"
    echo "  ZIG_CXX:    ${ZIG_CXX}"
    echo "  ZIG_ASM:    ${ZIG_ASM}"
    echo "  ZIG_AR:     ${ZIG_AR}"
    echo "  ZIG_RANLIB: ${ZIG_RANLIB}"
    echo "  ZIG_RC:     ${ZIG_RC}"
    echo "  Target:     ${target}"
    echo "  MCPU:       ${mcpu}"
    echo "  (Cleared CFLAGS/LDFLAGS - zig handles optimization internally)"
}

# LLVM-CONFIG WRAPPER

# Create a filtered llvm-config wrapper that removes flags unsupported by zig's linker
# Args:
#   $1 - Path to llvm-config binary to wrap
# Creates a wrapper in place that filters out -Bsymbolic-functions and similar flags
create_filtered_llvm_config() {
    local llvm_config="$1"

    if [[ ! -x "${llvm_config}" ]]; then
        echo "ERROR: llvm-config not found or not executable: ${llvm_config}" >&2
        return 1
    fi

    # Don't wrap if already wrapped
    if [[ -f "${llvm_config}.real" ]]; then
        echo "  llvm-config already wrapped: ${llvm_config}"
        return 0
    fi

    echo "Creating filtered llvm-config wrapper: ${llvm_config}"
    mv "${llvm_config}" "${llvm_config}.real"

    cat > "${llvm_config}" << 'WRAPPER_EOF'
#!/usr/bin/env bash
# Wrapper for llvm-config that filters out flags unsupported by zig's linker
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REAL_CONFIG="${SCRIPT_DIR}/$(basename "$0").real"

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
    chmod +x "${llvm_config}"
    echo "  ✓ Created wrapper: ${llvm_config}"
}

# BOOTSTRAP UTILITIES

# Install bootstrap zig using mamba (avoids recipe cycle detection)
# Usage: install_bootstrap_zig [version] [build_string]
# Example: install_bootstrap_zig "0.15.2" "*_7"
function install_bootstrap_zig() {
    local version="${1:-0.15.2}"
    local build_string="${2:-*_7}"
    local spec="zig==${version} ${build_string}"

    echo "=== Installing bootstrap zig via mamba ==="
    echo "  Spec: ${spec}"

    # Use mamba/conda to install zig into BUILD_PREFIX
    if command -v mamba &> /dev/null; then
        mamba install -p "${BUILD_PREFIX}" -y -c conda-forge "${spec}" || {
            echo "ERROR: Failed to install bootstrap zig" >&2
            return 1
        }
    elif command -v conda &> /dev/null; then
        conda install -p "${BUILD_PREFIX}" -y -c conda-forge "${spec}" || {
            echo "ERROR: Failed to install bootstrap zig" >&2
            return 1
        }
    else
        echo "ERROR: Neither mamba nor conda found" >&2
        return 1
    fi

    # Verify installation
    if [[ -x "${BUILD_PREFIX}/bin/zig" ]]; then
        echo "  ✓ Bootstrap zig installed: $(${BUILD_PREFIX}/bin/zig version)"
        export BOOTSTRAP_ZIG="${BUILD_PREFIX}/bin/zig"
    else
        echo "ERROR: zig not found after installation" >&2
        return 1
    fi

    echo "=== Bootstrap zig ready ==="
}

# Filter out arguments matching patterns from an array
# Usage: filter_array_args ARRAY_NAME "pattern1" "pattern2" ...
# Example: filter_array_args EXTRA_CMAKE_ARGS "-DZIG_SYSTEM_LIBCXX=*" "-DZIG_USE_LLVM_CONFIG=*"
function filter_array_args() {
  local array_name="$1"
  shift  # Remove array name, rest are patterns to filter

  # Use nameref to work with the array indirectly
  local -n arr_ref="$array_name"
  local new_args=()
  local arg
  local pattern
  local skip

  for arg in "${arr_ref[@]}"; do
    skip=false
    for pattern in "$@"; do
      case "$arg" in
        $pattern) skip=true; break ;;
      esac
    done

    if [[ "$skip" == "false" ]]; then
      new_args+=("$arg")
    fi
  done

  # Replace original array
  arr_ref=("${new_args[@]}")
}

function cmake_build_install() {
  local build_dir=$1

  local current_dir
  current_dir=$(pwd)

  cd "${build_dir}" || return 1
    cmake --build . -- -j"${CPU_COUNT}" || return 1
    cmake --install . || return 1
  cd "${current_dir}" || return 1
}

# ARCHIVED: GCC-BASED BUILD HELPERS (Bootstrap/Fallback only)
# These functions are kept for bootstrap/fallback builds using GCC as the C/C++
# compiler. When using zig cc (setup_zig_cc), these workarounds are NOT needed
# because zig bundles its own libc headers and handles sysroot internally.
#
# Functions in this section:
#   - modify_libc_libm_for_zig: Fix linker scripts for GCC sysroot (zig doesn't need)
#   - patch_crt_object: Patch CRT objects for GCC 14 + glibc 2.28 (zig doesn't need)
#   - create_gcc14_glibc28_compat_lib: Create stub library for GCC 14 (zig doesn't need)
#   - create_pthread_atfork_stub: Create pthread_atfork stub (zig doesn't need)
#   - build_lld_ppc64le_mcmodel: Build LLD for ppc64le (only for zig link step on ppc64le)
#
# To use GCC-based builds, set ZIG_BUILD_MODE=bootstrap in the environment.

function modify_libc_libm_for_zig() {
  local prefix=${1:-$PREFIX}
  local sysroot_arch=${2:-${SYSROOT_ARCH:-x86_64}}

  # Helper: Check if file is a text/script file (linker script)
  is_text_file() {
    local file=$1
    [[ -f "$file" ]] && file "$file" | grep -qE "ASCII text|script"
  }

  # Replace libc.so and libm.so linker scripts with symlinks (Zig doesn't support relative paths in linker scripts)
  # The linker scripts contain relative paths like "libc.so.6" which Zig can't handle (hits TODO panic at line 1074)
  # Just replace them with symlinks directly to the actual .so files
  local libc_path="${prefix}/${sysroot_arch}-conda-linux-gnu/sysroot/usr/lib64/libc.so"
  if is_text_file "$libc_path"; then
    echo "  - Replacing libc.so linker script with symlink"
    rm -f "$libc_path"
    ln -sf ../../lib64/libc.so.6 "$libc_path"
  fi

  local libm_path="${prefix}/${sysroot_arch}-conda-linux-gnu/sysroot/usr/lib64/libm.so"
  if is_text_file "$libm_path"; then
    echo "  - Replacing libm.so linker script with symlink"
    rm -f "$libm_path"
    ln -sf ../../lib64/libm.so.6 "$libm_path"
  fi

  # Replace libgcc_s.so linker scripts with symlinks (Zig doesn't support relative paths in linker scripts)
  # The linker scripts contain "GROUP ( libgcc_s.so.1 )" which is a relative path - Zig can't handle this
  # Just replace the linker script with a symlink directly to the actual .so file
  while IFS= read -r -d '' libgcc_file; do
    if is_text_file "$libgcc_file"; then
      echo "  - Replacing $(basename $(dirname "$libgcc_file"))/libgcc_s.so linker script with symlink"
      rm -f "$libgcc_file"
      ln -sf libgcc_s.so.1 "$libgcc_file"
    fi
  done < <(find "${prefix}" -name "libgcc_s.so" -type f -print0 2>/dev/null)

  # Remove problematic ncurses linker scripts (Zig doesn't support relative paths in linker scripts)
  # The linker scripts reference libncurses.so.6 which is a relative path - Zig can't handle this
  # Just remove the linker script and create a symlink directly to the actual .so file
  local ncurses_path="${prefix}/lib/libncurses.so"
  if [[ -f "$ncurses_path" ]]; then
    echo "  - Replacing libncurses.so with symlink"
    rm -f "$ncurses_path"
    ln -sf libncurses.so.6 "$ncurses_path"
  fi

  local ncursesw_path="${prefix}/lib/libncursesw.so"
  if [[ -f "$ncursesw_path" ]]; then
    echo "  - Replacing libncursesw.so with symlink"
    rm -f "$ncursesw_path"
    ln -sf libncursesw.so.6 "$ncursesw_path"
  fi

  # Zig doesn't yet support custom lib search paths, so symlink needed libs to where Zig looks
  # Create symlinks from lib64 to usr/lib (Zig searches usr/lib by default)
  local sysroot="${prefix}/${sysroot_arch}-conda-linux-gnu/sysroot"
  echo "  - Creating symlinks in usr/lib for lib64 libraries"

  # Suppress error if symlink already exists
  ln -sf ../../../lib64/libm.so.6 "${sysroot}/usr/lib/libm.so.6" 2>/dev/null || true
  ln -sf ../../../lib64/libmvec.so.1 "${sysroot}/usr/lib/libmvec.so.1" 2>/dev/null || true
  ln -sf ../../../lib64/libc.so.6 "${sysroot}/usr/lib/libc.so.6" 2>/dev/null || true

  # Architecture-specific dynamic linker symlinks
  case "${sysroot_arch}" in
    aarch64)
      ln -sf ../../../lib64/ld-linux-aarch64.so.1 "${sysroot}/usr/lib/ld-linux-aarch64.so.1" 2>/dev/null || true
      ;;
    powerpc64le)
      ln -sf ../../../lib64/ld64.so.2 "${sysroot}/usr/lib/ld64.so.2" 2>/dev/null || true
      ;;
    x86_64)
      ln -sf ../../../lib64/ld-linux-x86-64.so.2 "${sysroot}/usr/lib/ld-linux-x86-64.so.2" 2>/dev/null || true
      ;;
  esac
}

# Patch a single CRT object file with __libc_csu_init/fini stubs
# Args:
#   $1 - Path to CRT object file
#   $2 - Stub directory containing architecture-specific stub objects
# Returns: 0 on success, 1 if patching not possible/needed
patch_crt_object() {
  local crt_path="$1"
  local stub_dir="$2"

  [[ -f "${crt_path}" ]] || return 1

  # Backup original
  cp "${crt_path}" "${crt_path}.backup" || return 1

  # Detect architecture of object file
  local file_output
  file_output=$(file "${crt_path}.backup")

  local obj_arch linker_cmd stub_obj
  case "${file_output}" in
    *x86-64*)
      obj_arch="x86-64"
      linker_cmd="${BUILD_PREFIX}/bin/x86_64-conda-linux-gnu-ld"
      stub_obj="${stub_dir}/libc_csu_stubs_x86_64.o"
      ;;
    *PowerPC*|*ppc64*)
      obj_arch="PowerPC64"
      linker_cmd="${BUILD_PREFIX}/bin/powerpc64le-conda-linux-gnu-ld"
      stub_obj="${stub_dir}/libc_csu_stubs_ppc64le.o"
      ;;
    *aarch64*|*ARM*64*)
      obj_arch="aarch64"
      linker_cmd="${BUILD_PREFIX}/bin/aarch64-conda-linux-gnu-ld"
      stub_obj="${stub_dir}/libc_csu_stubs_aarch64.o"
      ;;
    *)
      # Unknown architecture - restore original and skip
      cp "${crt_path}.backup" "${crt_path}"
      return 1
      ;;
  esac

  # Check if stub object exists for this architecture
  if [[ ! -f "${stub_obj}" ]]; then
    cp "${crt_path}.backup" "${crt_path}"
    return 1
  fi

  # Use 'ld -r' to combine the original and stub objects
  if ! "${linker_cmd}" -r -o "${crt_path}.tmp" "${crt_path}.backup" "${stub_obj}" 2>/dev/null; then
    # Linking failed - restore original and skip
    cp "${crt_path}.backup" "${crt_path}"
    return 1
  fi

  # Replace original with combined version
  mv "${crt_path}.tmp" "${crt_path}"
  echo "    ✓ Patched $(basename "${crt_path}") [${obj_arch}]" >&2
  return 0
}

# Create GCC 14 + glibc 2.28 compatibility library
# GCC 14 removed __libc_csu_init and __libc_csu_fini from crtbegin/crtend
# but glibc 2.28 crt1.o still references them
function create_gcc14_glibc28_compat_lib() {
  local prefix="${1:-$BUILD_PREFIX}"
  
  local stub_dir="${prefix}/lib/gcc14-glibc28-compat"
  mkdir -p "${stub_dir}" || return 1

  # Create stub source file
  cat > "${stub_dir}/libc_csu_stubs.c" << 'EOF'
/* Stub implementations for GCC 14 + glibc 2.28 compatibility */
void __libc_csu_init(void) {
    /* Empty - old-style static constructors not used anymore */
}

void __libc_csu_fini(void) {
    /* Empty - old-style static destructors not used anymore */
}
EOF

  echo "Compiling CSU stubs for available architectures..."

  # Compile stub objects for all available architectures
  # We need architecture-specific object files to patch architecture-specific CRT files
  local arch_compilers=(
    "x86_64:${prefix}/bin/x86_64-conda-linux-gnu-cc:libc_csu_stubs_x86_64.o"
    "powerpc64le:${prefix}/bin/powerpc64le-conda-linux-gnu-cc:libc_csu_stubs_ppc64le.o"
    "aarch64:${prefix}/bin/aarch64-conda-linux-gnu-cc:libc_csu_stubs_aarch64.o"
  )

  for entry in "${arch_compilers[@]}"; do
    IFS=: read -r arch compiler output <<< "${entry}"
    if [[ -x "${compiler}" ]]; then
      echo "  - Compiling for ${arch}"
      "${compiler}" -c "${stub_dir}/libc_csu_stubs.c" -o "${stub_dir}/${output}" || {
        echo "    Warning: Failed to compile for ${arch}" >&2
      }
    fi
  done

  # Create static library using the current target architecture
  echo "Creating static library..."
  "${CC}" -c "${stub_dir}/libc_csu_stubs.c" -o "${stub_dir}/libc_csu_stubs.o" || return 1
  "${AR}" rcs "${stub_dir}/libcsu_compat.a" "${stub_dir}/libc_csu_stubs.o" || return 1

  # Copy to standard library location
  cp "${stub_dir}/libcsu_compat.a" "${prefix}/lib/" || return 1

  # Patch glibc crt1.o files which reference __libc_csu_init/fini
  # NOTE: We do NOT patch GCC's crtbegin*.o files to avoid duplicate symbol definitions
  echo "Patching glibc crt1.o files..."
  local crt_files=(crt1.o Scrt1.o gcrt1.o grcrt1.o)

  for sysroot_dir in "${prefix}"/*-conda-linux-gnu/sysroot/usr/lib; do
    [[ -d "${sysroot_dir}" ]] || continue

    for crt_file in "${crt_files[@]}"; do
      patch_crt_object "${sysroot_dir}/${crt_file}" "${stub_dir}" || true
    done
  done

  echo "Created GCC 14 + glibc 2.28 compatibility:"
  echo "  - ${prefix}/lib/libcsu_compat.a"
  echo "  - Patched all glibc crt1*.o files with stub symbols"
}

function configure_cmake() {
  local build_dir=$1
  local install_dir=$2
  local zig=${3:-}

  # Build local cmake args array
  local cmake_args=()

  # Add zig compiler configuration if provided
  # Prefer ZIG_CC/ZIG_CXX from setup_zig_cc, fallback to legacy zig parameter
  if [[ -n "${ZIG_CC:-}" ]] && [[ -n "${ZIG_CXX:-}" ]]; then
    # Use wrappers created by setup_zig_cc (preferred)
    cmake_args+=("-DCMAKE_C_COMPILER=${ZIG_CC}")
    cmake_args+=("-DCMAKE_CXX_COMPILER=${ZIG_CXX}")
    cmake_args+=("-DCMAKE_AR=${ZIG_AR:-${zig:-ar}}")
    cmake_args+=("-DCMAKE_RANLIB=${ZIG_RANLIB:-ranlib}")
  elif [[ -n "${zig}" ]]; then
    # Legacy path: construct zig compiler args (requires ZIG_TARGET)
    local _target="${ZIG_TARGET:-x86_64-linux-gnu}"
    local _c="${zig};cc;-target;${_target};-mcpu=${MCPU:-baseline}"
    local _cxx="${zig};c++;-target;${_target};-mcpu=${MCPU:-baseline}"

    # Add QEMU flag for native (non-cross) compilation
    if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "0" ]]; then
      _c="${_c};-fqemu"
      _cxx="${_cxx};-fqemu"
    fi

    cmake_args+=("-DCMAKE_C_COMPILER=${_c}")
    cmake_args+=("-DCMAKE_CXX_COMPILER=${_cxx}")
    cmake_args+=("-DCMAKE_AR=${zig}")
    cmake_args+=("-DZIG_AR_WORKAROUND=ON")
  fi

  # Merge with global EXTRA_CMAKE_ARGS if it exists
  # Use ${var+x} syntax for bash 3.2 compatibility (macOS default bash)
  if [[ -n "${EXTRA_CMAKE_ARGS+x}" ]]; then
    cmake_args+=("${EXTRA_CMAKE_ARGS[@]}")
  fi

  # Add CMAKE_ARGS from environment if requested
  if [[ ${USE_CMAKE_ARGS:-0} == 1 ]]; then
    IFS=' ' read -r -a cmake_args_from_env <<< "${CMAKE_ARGS:-}"
    cmake_args+=("${cmake_args_from_env[@]}")
  fi

  # Create build directory and run cmake
  mkdir -p "${build_dir}" || return 1

  (
    cd "${build_dir}" &&
    cmake "${cmake_source_dir}" \
      -D CMAKE_INSTALL_PREFIX="${install_dir}" \
      "${cmake_args[@]}" \
      -G Ninja
  ) || return 1
}

function configure_cmake_zigcpp() {
  local build_dir=$1
  local install_dir=$2
  local zig=${3:-}

  configure_cmake "${build_dir}" "${install_dir}" "${zig}"
  pushd "${build_dir}"
    cmake --build . --target zigcpp -- -j"${CPU_COUNT}"
  popd
}

function setup_crosscompiling_emulator() {
  local qemu_prg=$1

  if [[ -z "${qemu_prg}" ]]; then
    echo "ERROR: qemu_prg parameter required for setup_crosscompiling_emulator" >&2
    return 1
  fi

  # Set CROSSCOMPILING_EMULATOR if not already set
  if [[ -z "${CROSSCOMPILING_EMULATOR:-}" ]]; then
    if [[ -f /usr/bin/"${qemu_prg}" ]]; then
      export CROSSCOMPILING_EMULATOR=/usr/bin/"${qemu_prg}"
      echo "Set CROSSCOMPILING_EMULATOR=${CROSSCOMPILING_EMULATOR}"
    else
      echo "ERROR: CROSSCOMPILING_EMULATOR not set and ${qemu_prg} not found in /usr/bin/" >&2
      return 1
    fi
  else
    echo "Using existing CROSSCOMPILING_EMULATOR=${CROSSCOMPILING_EMULATOR}"
  fi

  return 0
}

function create_qemu_llvm_config_wrapper() {
  local sysroot_path=$1

  if [[ -z "${sysroot_path}" ]]; then
    echo "ERROR: sysroot_path parameter required for create_qemu_llvm_config_wrapper" >&2
    return 1
  fi

  if [[ -z "${CROSSCOMPILING_EMULATOR:-}" ]]; then
    echo "ERROR: CROSSCOMPILING_EMULATOR must be set before calling create_qemu_llvm_config_wrapper" >&2
    return 1
  fi

  echo "Creating QEMU wrapper for llvm-config"

  # Backup original llvm-config
  mv "${PREFIX}"/bin/llvm-config "${PREFIX}"/bin/llvm-config.zig_conda_real || return 1

  # Create wrapper script that runs llvm-config under QEMU
  cat > "${PREFIX}"/bin/llvm-config << EOF
#!/usr/bin/env bash
export QEMU_LD_PREFIX="${sysroot_path}"
"${CROSSCOMPILING_EMULATOR}" "${PREFIX}"/bin/llvm-config.zig_conda_real "\$@"
EOF

  chmod +x "${PREFIX}"/bin/llvm-config || return 1
  echo "✓ llvm-config wrapper created"
  return 0
}

function remove_qemu_llvm_config_wrapper() {
  if [[ -f "${PREFIX}"/bin/llvm-config.zig_conda_real ]]; then
    rm -f "${PREFIX}"/bin/llvm-config && mv "${PREFIX}"/bin/llvm-config.zig_conda_real "${PREFIX}"/bin/llvm-config || return 1
  fi
  return 0
}

function create_zig_libc_file() {
  local output_file=$1
  local sysroot_path=$2
  local sysroot_arch=$3

  if [[ -z "${output_file}" ]] || [[ -z "${sysroot_path}" ]] || [[ -z "${sysroot_arch}" ]]; then
    echo "ERROR: create_zig_libc_file requires: output_file, sysroot_path, sysroot_arch" >&2
    return 1
  fi

  echo "Creating Zig libc configuration file: ${output_file}"

  # Find GCC library directory (contains crtbegin.o, crtend.o)
  local gcc_lib_dir
  gcc_lib_dir=$(dirname "$(find "${BUILD_PREFIX}"/lib/gcc/${sysroot_arch}-conda-linux-gnu -name "crtbeginS.o" | head -1)")

  if [[ -z "${gcc_lib_dir}" ]] || [[ ! -d "${gcc_lib_dir}" ]]; then
    echo "WARNING: Could not find GCC library directory for ${sysroot_arch}" >&2
    gcc_lib_dir=""
  else
    echo "  Found GCC library directory: ${gcc_lib_dir}"
  fi

  # Create libc configuration file
  cat > "${output_file}" << EOF
include_dir=${sysroot_path}/usr/include
sys_include_dir=${sysroot_path}/usr/include
crt_dir=${sysroot_path}/usr/lib
msvc_lib_dir=
kernel32_lib_dir=
gcc_dir=${gcc_lib_dir}
EOF

  echo "✓ Zig libc file created: ${output_file}"
  return 0
}

function apply_cmake_patches() {
  local build_dir=$1

  # Check if CMAKE_PATCHES array exists and has elements
  if [[ -z "${CMAKE_PATCHES+x}" ]] || [[ ${#CMAKE_PATCHES[@]} -eq 0 ]]; then
    echo "No CMAKE_PATCHES defined, skipping patch application"
    return 0
  fi

  echo "Applying ${#CMAKE_PATCHES[@]} cmake patches to ${build_dir}"

  local patch_dir="${RECIPE_DIR}/patches/cmake"
  if [[ ! -d "${patch_dir}" ]]; then
    echo "ERROR: Patch directory ${patch_dir} does not exist" >&2
    return 1
  fi

  pushd "${build_dir}" > /dev/null || return 1
    for patch_file in "${CMAKE_PATCHES[@]}"; do
      local patch_path="${patch_dir}/${patch_file}"
      if [[ ! -f "${patch_path}" ]]; then
        echo "ERROR: Patch file ${patch_path} not found" >&2
        popd > /dev/null
        return 1
      fi

      echo "  Applying patch: ${patch_file}"
      if patch -p1 < "${patch_path}"; then
        echo "    ✓ ${patch_file} applied successfully"
      else
        echo "ERROR: Failed to apply patch ${patch_file}" >&2
        popd > /dev/null
        return 1
      fi
    done
  popd > /dev/null

  echo "All cmake patches applied successfully"
  return 0
}

function build_zig_with_zig() {
  local build_dir=$1
  local zig=$2
  local install_dir=$3

  local current_dir
  current_dir=$(pwd)

  if [[ -d "${build_dir}" ]]; then
    cd "${build_dir}" || return 1
      "${zig}" build \
        --prefix "${install_dir}" \
        ${EXTRA_ZIG_ARGS[@]+"${EXTRA_ZIG_ARGS[@]}"} \
        -Dversion-string="${PKG_VERSION}" || return 1
        # --search-prefix "${install_dir}" \
    cd "${current_dir}" || return 1
  else
    echo "No build directory found" >&2
    return 1
  fi
}

function remove_failing_langref() {
  local build_dir=$1
  local testslistfile=${2:-"${SRC_DIR}"/build-level-patches/xxxx-remove-langref-std.txt}

  local current_dir
  current_dir=$(pwd)

  if [[ -d "${build_dir}"/doc/langref ]]; then
    # These langref code snippets fails with lld.ld failing to find /usr/lib64/libmvec_nonshared.a
    # No idea why this comes up, there is no -lmvec_nonshared.a on the link command
    # there seems to be no way to redirect to sysroot/usr/lib64/libmvec_nonshared.a
    grep -v -f "${testslistfile}" "${build_dir}"/doc/langref.html.in > "${build_dir}"/doc/_langref.html.in
    mv "${build_dir}"/doc/_langref.html.in "${build_dir}"/doc/langref.html.in
    while IFS= read -r file
    do
      rm -f "${build_dir}"/doc/langref/"$file"
    done < "${SRC_DIR}"/build-level-patches/xxxx-remove-langref-std.txt
  else
    echo "No langref directory found"
    exit 1
  fi
}

function create_pthread_atfork_stub() {
  # Create pthread_atfork stub for glibc 2.28 on PowerPC64LE and aarch64
  # glibc 2.28 for these architectures doesn't export pthread_atfork symbol
  # (x86_64 glibc 2.28 has it, but PowerPC64LE and aarch64 don't)

  local arch_name="${1}"
  local cc_compiler="${2}"
  local output_dir="${3:-${SRC_DIR}}"

  echo "=== Creating pthread_atfork stub for glibc 2.28 ${arch_name} ==="

  cat > "${output_dir}/pthread_atfork_stub.c" << 'EOF'
// Weak stub for pthread_atfork when glibc 2.28 doesn't provide it
// This is safe because Zig compiler doesn't actually use fork()
__attribute__((weak))
int pthread_atfork(void (*prepare)(void), void (*parent)(void), void (*child)(void)) {
    // Stub implementation - returns success without doing anything
    // (void) casts suppress unused parameter warnings
    (void)prepare;
    (void)parent;
    (void)child;
    return 0;  // Success
}
EOF

  "${cc_compiler}" -c "${output_dir}/pthread_atfork_stub.c" -o "${output_dir}/pthread_atfork_stub.o" || {
    echo "ERROR: Failed to compile pthread_atfork stub" >&2
    return 1
  }

  if [[ ! -f "${output_dir}/pthread_atfork_stub.o" ]]; then
    echo "ERROR: pthread_atfork_stub.o was not created" >&2
    return 1
  fi

  echo "=== pthread_atfork stub created: ${output_dir}/pthread_atfork_stub.o ==="
}

function build_cmake_lld() {
  local build_dir=$1
  local install_dir=$2

  local current_dir
  current_dir=$(pwd)

  mkdir -p "${build_dir}"
  cd "${build_dir}" || exit 1
    cmake "$ROOTDIR/llvm" \
      -DCMAKE_INSTALL_PREFIX="${install_dir}" \
      -DCMAKE_BUILD_TYPE=Release \
      -DLLVM_ENABLE_BINDINGS=OFF \
      -DLLVM_ENABLE_LIBEDIT=OFF \
      -DLLVM_ENABLE_LIBPFM=OFF \
      -DLLVM_ENABLE_LIBXML2=ON \
      -DLLVM_ENABLE_OCAMLDOC=OFF \
      -DLLVM_ENABLE_PLUGINS=OFF \
      -DLLVM_ENABLE_PROJECTS="lld" \
      -DLLVM_ENABLE_Z3_SOLVER=OFF \
      -DLLVM_ENABLE_ZSTD=ON \
      -DLLVM_INCLUDE_UTILS=OFF \
      -DLLVM_INCLUDE_TESTS=OFF \
      -DLLVM_INCLUDE_EXAMPLES=OFF \
      -DLLVM_INCLUDE_BENCHMARKS=OFF \
      -DLLVM_INCLUDE_DOCS=OFF \
      -DLLVM_TOOL_LLVM_LTO2_BUILD=OFF \
      -DLLVM_TOOL_LLVM_LTO_BUILD=OFF \
      -DLLVM_TOOL_LTO_BUILD=OFF \
      -DLLVM_TOOL_REMARKS_SHLIB_BUILD=OFF \
      -DCLANG_BUILD_TOOLS=OFF \
      -DCLANG_INCLUDE_DOCS=OFF \
      -DCLANG_INCLUDE_TESTS=OFF \
      -DCLANG_TOOL_CLANG_IMPORT_TEST_BUILD=OFF \
      -DCLANG_TOOL_CLANG_LINKER_WRAPPER_BUILD=OFF \
      -DCLANG_TOOL_C_INDEX_TEST_BUILD=OFF \
      -DCLANG_TOOL_LIBCLANG_BUILD=OFF
    cmake --build . --target install
  cd "${current_dir}" || exit 1
}

function build_lld_ppc64le_mcmodel() {
  # Build LLD libraries for PowerPC64LE with -mcmodel=medium to avoid R_PPC64_REL24 truncation
  # Similar to configure_cmake_zigcpp but for LLD libraries

  local llvm_source_dir=$1
  local build_dir=$2
  local target_arch="${3:-linux-ppc64le}"

  # Build LLD from scratch with mcmodel=medium
  echo "Building LLD libraries for PowerPC64LE with -mcmodel=medium..."

  local current_dir
  current_dir=$(pwd)

  mkdir -p "${build_dir}"
  cd "${build_dir}" || exit 1

  # Configure LLVM to build only LLD libraries
  cmake "${llvm_source_dir}/lld" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER="${CC}" \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DLLVM_ENABLE_PROJECTS="lld" \
    -DLLVM_TARGETS_TO_BUILD="PowerPC" \
    -DLLVM_BUILD_TOOLS=OFF \
    -DLLVM_INCLUDE_TOOLS=OFF \
    -DLLVM_BUILD_UTILS=OFF \
    -DLLVM_INCLUDE_UTILS=OFF \
    -DLLVM_BUILD_TESTS=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_BUILD_EXAMPLES=OFF \
    -DLLVM_INCLUDE_EXAMPLES=OFF \
    -DLLVM_BUILD_BENCHMARKS=OFF \
    -DLLVM_INCLUDE_BENCHMARKS=OFF \
    -DLLVM_BUILD_DOCS=OFF \
    -DLLVM_INCLUDE_DOCS=OFF \
    -DLLVM_CONFIG_PATH=$BUILD_PREFIX/bin/llvm-config \
    -DLLVM_TABLEGEN_EXE=$BUILD_PREFIX/bin/llvm-tblgen \
    -DLLVM_ENABLE_RTTI=ON \
    -G Ninja

  # Build all LLD libraries (they're defined as add_lld_library in lld/*/CMakeLists.txt)
  # Target names: lldELF, lldCommon, lldCOFF, lldMachO, lldWasm, lldMinGW
  cmake --build . -- -j${CPU_COUNT}

  cd "${current_dir}" || exit 1
}

# BUILD MODE DETECTION (Phase 5 - Compiler Package)

# === Build Mode Detection ===
# Determines build mode based on TG_, target_platform, and cross-compilation flag
#
# Build modes:
#   native:         TG_ == target_platform == build_platform
#   cross-compiler: TG_ != target_platform (building cross-compiler)
#   cross-target:   TG_ == target_platform but CONDA_BUILD_CROSS_COMPILATION=1
#
# Returns: Sets BUILD_MODE, IS_CROSS_* variables
# Note: ZIG_TARGET is provided by recipe.yaml - no mapping needed here
detect_build_mode() {
    local tg="${TG_:-${target_platform}}"

    # Build mode detection
    if [[ "${tg}" != "${target_platform}" ]]; then
        BUILD_MODE="cross-compiler"
        IS_CROSS_COMPILER=1
        IS_CROSS_TARGET=0
        IS_NATIVE=0
    elif [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "1" ]]; then
        BUILD_MODE="cross-target"
        IS_CROSS_COMPILER=0
        IS_CROSS_TARGET=1
        IS_NATIVE=0
    else
        BUILD_MODE="native"
        IS_CROSS_COMPILER=0
        IS_CROSS_TARGET=0
        IS_NATIVE=1
    fi

    export BUILD_MODE IS_CROSS_COMPILER IS_CROSS_TARGET IS_NATIVE

    echo "=== Build Mode Detection ==="
    echo "TG_:             ${tg}"
    echo "target_platform: ${target_platform}"
    echo "build_platform:  ${build_platform:-unknown}"
    echo "BUILD_MODE:      ${BUILD_MODE}"
    echo "ZIG_TARGET:      ${ZIG_TARGET:-not set}"
    echo "============================"
}

# === Triplet Environment Variables ===
# These are provided by the conda build environment - no need to duplicate mapping:
#   CONDA_TOOLCHAIN_BUILD  - Build host triplet (e.g., x86_64-conda-linux-gnu)
#   CONDA_TOOLCHAIN_HOST   - Target host triplet (e.g., aarch64-conda-linux-gnu)
#   ZIG_TARGET             - Zig -target argument (from recipe.yaml script env)
#
# When adding new architectures (e.g., riscv64), only edit:
#   1. variants.yaml - add TG_ value
#   2. recipe.yaml - add zig_target mapping (single source of truth)
#   3. Below function - only if zig target differs from Linux pattern (macOS/Windows)

# === Derive Zig Target from Conda Triplet ===
# Converts CONDA_TOOLCHAIN_HOST to zig -target format
# For Linux: removes '-conda-' (e.g., aarch64-conda-linux-gnu → aarch64-linux-gnu)
# For macOS/Windows: explicit mapping (different naming conventions)
derive_zig_target() {
    local conda_triplet="$1"

    case "${conda_triplet}" in
        # macOS: darwin → macos-none, arm64 → aarch64
        x86_64-conda-darwin)
            echo "x86_64-macos-none" ;;
        arm64-conda-darwin)
            echo "aarch64-macos-none" ;;
        # Windows: w64-mingw32 → windows-gnu
        x86_64-conda-w64-mingw32)
            echo "x86_64-windows-gnu" ;;
        # Linux and future archs: just remove '-conda-'
        *)
            echo "${conda_triplet//-conda-/-}" ;;
    esac
}

# === Installation Prefix for Current Build Mode ===
# Returns the appropriate installation prefix based on build mode
get_install_prefix() {
    local base_prefix="${1:-${PREFIX}}"

    case "${BUILD_MODE}" in
        native)
            echo "${base_prefix}"
            ;;
        cross-compiler)
            # Cross-compilers install to subdirectory
            echo "${base_prefix}/lib/zig-cross-compilers/${TARGET_TRIPLET}"
            ;;
        cross-target)
            # Cross-target is like native (target platform binaries)
            echo "${base_prefix}"
            ;;
        *)
            echo "${base_prefix}"
            ;;
    esac
}

# === Binary Prefix for Cross-Compilers ===
# Returns prefix for cross-compiler binary names (e.g., "aarch64-linux-gnu-")
get_binary_prefix() {
    case "${BUILD_MODE}" in
        cross-compiler)
            echo "${TARGET_TRIPLET}-"
            ;;
        *)
            echo ""
            ;;
    esac
}

# === Install Activation Scripts ===
# Installs conda activation/deactivation scripts with placeholder substitution
install_activation_scripts() {
    local prefix="$1"
    local target_triplet="${2:-}"  # Empty for native builds

    # Create directories
    mkdir -p "${prefix}/etc/conda/activate.d"
    mkdir -p "${prefix}/etc/conda/deactivate.d"

    # Determine compiler basenames
    local cc_basename=$(basename "${CC:-cc}")
    local cxx_basename=$(basename "${CXX:-c++}")
    local ar_basename=$(basename "${AR:-ar}")
    local ld_basename=$(basename "${LD:-ld}")

    # Process and install activation script
    sed -e "s|@CC@|${cc_basename}|g" \
        -e "s|@CXX@|${cxx_basename}|g" \
        -e "s|@AR@|${ar_basename}|g" \
        -e "s|@LD@|${ld_basename}|g" \
        -e "s|@CROSS_TARGET_TRIPLET@|${target_triplet}|g" \
        "${RECIPE_DIR}/scripts/activate.sh" \
        > "${prefix}/etc/conda/activate.d/zig_activate.sh"

    # Process and install deactivation script
    cp "${RECIPE_DIR}/scripts/deactivate.sh" \
       "${prefix}/etc/conda/deactivate.d/zig_deactivate.sh"

    # Make executable
    chmod +x "${prefix}/etc/conda/activate.d/zig_activate.sh"
    chmod +x "${prefix}/etc/conda/deactivate.d/zig_deactivate.sh"

    # Windows scripts (if applicable)
    if [[ "${target_platform}" == win-* ]]; then
        sed -e "s|@CC@|${cc_basename}|g" \
            -e "s|@CXX@|${cxx_basename}|g" \
            -e "s|@AR@|${ar_basename}|g" \
            -e "s|@LD@|${ld_basename}|g" \
            "${RECIPE_DIR}/scripts/activate.bat" \
            > "${prefix}/etc/conda/activate.d/zig_activate.bat"

        cp "${RECIPE_DIR}/scripts/deactivate.bat" \
           "${prefix}/etc/conda/deactivate.d/zig_deactivate.bat"
    fi

    echo "Activation scripts installed to ${prefix}/etc/conda/"
}

# === Install Wrapper Scripts ===
# Installs toolchain wrapper scripts (conda-zig-cc, etc.)
install_wrapper_scripts() {
    local prefix="$1"

    mkdir -p "${prefix}/bin"

    for wrapper in "${RECIPE_DIR}"/scripts/wrappers/conda-zig-*; do
        if [[ -f "${wrapper}" ]]; then
            local basename=$(basename "${wrapper}")
            cp "${wrapper}" "${prefix}/bin/${basename}"
            chmod +x "${prefix}/bin/${basename}"
        fi
    done

    echo "Wrapper scripts installed to ${prefix}/bin/"
}

# === Generate Triplet-Prefixed Wrappers ===
# Creates native triplet wrappers that forward to unprefixed zig binary
# Used by native packages to provide consistent naming across platforms
generate_native_triplet_wrappers() {
    local prefix="$1"
    local conda_triplet="$2"  # e.g., x86_64-conda-linux-gnu

    mkdir -p "${prefix}/bin"

    # Main triplet wrapper → unprefixed zig
    cat > "${prefix}/bin/${conda_triplet}-zig" << 'EOF'
#!/usr/bin/env bash
exec "${CONDA_PREFIX}/bin/zig" "$@"
EOF
    chmod +x "${prefix}/bin/${conda_triplet}-zig"

    # Tool wrappers (cc, c++, ar)
    for tool in cc c++ ar; do
        cat > "${prefix}/bin/${conda_triplet}-zig-${tool}" << EOF
#!/usr/bin/env bash
exec "\${CONDA_PREFIX}/bin/zig" ${tool} "\$@"
EOF
        chmod +x "${prefix}/bin/${conda_triplet}-zig-${tool}"
    done

    echo "Native triplet wrappers installed: ${conda_triplet}-zig[-cc|-c++|-ar]"
}

# === Generate Cross-Compiler Wrappers ===
# Creates cross-compiler wrappers with target triplet prefix
# These invoke the native zig with -target flag
generate_cross_wrappers() {
    local prefix="$1"
    local native_triplet="$2"   # e.g., x86_64-conda-linux-gnu (runs on build host)
    local target_triplet="$3"   # e.g., aarch64-conda-linux-gnu (target platform)
    local zig_target="$4"       # e.g., aarch64-linux-gnu (zig -target arg)

    mkdir -p "${prefix}/bin"

    # Main cross-compiler wrapper: target-zig → native-zig -target <target>
    cat > "${prefix}/bin/${target_triplet}-zig" << EOF
#!/usr/bin/env bash
exec "\${CONDA_PREFIX}/bin/${native_triplet}-zig" -target ${zig_target} "\$@"
EOF
    chmod +x "${prefix}/bin/${target_triplet}-zig"

    # Tool wrappers (cc, c++, ar)
    for tool in cc c++ ar; do
        cat > "${prefix}/bin/${target_triplet}-zig-${tool}" << EOF
#!/usr/bin/env bash
exec "\${CONDA_PREFIX}/bin/${native_triplet}-zig" ${tool} -target ${zig_target} "\$@"
EOF
        chmod +x "${prefix}/bin/${target_triplet}-zig-${tool}"
    done

    echo "Cross-compiler wrappers installed: ${target_triplet}-zig[-cc|-c++|-ar]"
    echo "  → Forward to ${native_triplet}-zig with -target ${zig_target}"
}

# CROSS-COMPILER INSTALLATION (Phase 7 - Compiler Package)

# === Install Cross-Compiler ===
# Installs zig as a cross-compiler using conda-style triplet wrappers
#
# Cross-compiler layout (e.g., zig_linux-aarch64 on linux-64):
#   $PREFIX/bin/x86_64-conda-linux-gnu-zig         # Native binary (runs on host)
#   $PREFIX/bin/x86_64-conda-linux-gnu-zig-cc      # Native tool wrapper
#   $PREFIX/bin/aarch64-conda-linux-gnu-zig        # Cross wrapper → native -target
#   $PREFIX/bin/aarch64-conda-linux-gnu-zig-cc     # Cross tool wrapper
#   $PREFIX/lib/zig/                               # Standard library (universal)
#
install_cross_compiler() {
    local source_dir="$1"
    local prefix="$2"

    echo "=== Installing Cross-Compiler ==="
    echo "Build host:     ${target_platform}"
    echo "Target (TG_):   ${TG_}"

    # Use environment variables set by conda build:
    #   CONDA_TOOLCHAIN_BUILD - native triplet (where build runs)
    #   CONDA_TOOLCHAIN_HOST  - target triplet (where binary runs)
    #   ZIG_TARGET            - zig -target argument (from recipe.yaml script env)
    local native_triplet="${CONDA_TOOLCHAIN_BUILD}"
    local target_triplet="${CONDA_TOOLCHAIN_HOST}"
    local zig_target="${ZIG_TARGET:-$(derive_zig_target "${target_triplet}")}"

    echo "Native triplet: ${native_triplet}"
    echo "Target triplet: ${target_triplet}"
    echo "Zig target:     ${zig_target}"

    # Install native zig binary (runs on build host)
    mkdir -p "${prefix}/bin"
    if [[ -f "${source_dir}/zig" ]]; then
        cp "${source_dir}/zig" "${prefix}/bin/${native_triplet}-zig"
    elif [[ -f "${source_dir}/bin/zig" ]]; then
        cp "${source_dir}/bin/zig" "${prefix}/bin/${native_triplet}-zig"
    else
        echo "ERROR: Cannot find zig binary in ${source_dir}"
        return 1
    fi
    chmod +x "${prefix}/bin/${native_triplet}-zig"

    # Create native tool wrappers
    for tool in cc c++ ar; do
        cat > "${prefix}/bin/${native_triplet}-zig-${tool}" << EOF
#!/usr/bin/env bash
exec "\${CONDA_PREFIX}/bin/${native_triplet}-zig" ${tool} "\$@"
EOF
        chmod +x "${prefix}/bin/${native_triplet}-zig-${tool}"
    done

    # Install standard library (universal across targets)
    mkdir -p "${prefix}/lib"
    if [[ -d "${source_dir}/lib/zig" ]]; then
        cp -r "${source_dir}/lib/zig" "${prefix}/lib/"
    elif [[ -d "${source_dir}/lib" ]]; then
        mkdir -p "${prefix}/lib/zig"
        cp -r "${source_dir}/lib/"* "${prefix}/lib/zig/"
    fi

    # Generate cross-compiler wrappers
    generate_cross_wrappers "${prefix}" "${native_triplet}" "${target_triplet}" "${zig_target}"

    echo "Cross-compiler installed:"
    echo "  Native:   ${prefix}/bin/${native_triplet}-zig"
    echo "  Cross:    ${prefix}/bin/${target_triplet}-zig"
    echo "  Wrappers: ${prefix}/bin/${target_triplet}-zig-{cc,c++,ar}"
    echo "  Stdlib:   ${prefix}/lib/zig/"
}

# === Install Native Compiler ===
# Installs zig as a native compiler with standard layout and triplet wrappers
#
# Layout:
#   $PREFIX/bin/zig                              # Unprefixed (convenience)
#   $PREFIX/bin/x86_64-conda-linux-gnu-zig       # Triplet-prefixed wrapper
#   $PREFIX/bin/x86_64-conda-linux-gnu-zig-cc    # Tool wrapper
#   $PREFIX/lib/zig/                             # Standard library
#
install_native_compiler() {
    local source_dir="$1"
    local prefix="$2"

    echo "=== Installing Native Compiler ==="

    # Use environment variable set by conda build:
    #   CONDA_TOOLCHAIN_HOST - target triplet (where binary runs)
    # For native builds, HOST == BUILD
    local conda_triplet="${CONDA_TOOLCHAIN_HOST}"
    echo "Conda triplet: ${conda_triplet}"

    # Install binary
    mkdir -p "${prefix}/bin"
    if [[ -f "${source_dir}/zig" ]]; then
        cp "${source_dir}/zig" "${prefix}/bin/zig"
    elif [[ -f "${source_dir}/bin/zig" ]]; then
        cp "${source_dir}/bin/zig" "${prefix}/bin/zig"
    else
        echo "ERROR: Cannot find zig binary in ${source_dir}"
        return 1
    fi
    chmod +x "${prefix}/bin/zig"

    # Install standard library
    mkdir -p "${prefix}/lib"
    if [[ -d "${source_dir}/lib/zig" ]]; then
        cp -r "${source_dir}/lib/zig" "${prefix}/lib/"
    elif [[ -d "${source_dir}/lib" ]]; then
        mkdir -p "${prefix}/lib/zig"
        cp -r "${source_dir}/lib/"* "${prefix}/lib/zig/"
    fi

    # Install documentation if present
    if [[ -d "${source_dir}/doc" ]]; then
        mkdir -p "${prefix}/doc"
        cp -r "${source_dir}/doc/"* "${prefix}/doc/"
    fi

    # Generate triplet-prefixed wrappers
    generate_native_triplet_wrappers "${prefix}" "${conda_triplet}"

    echo "Native compiler installed:"
    echo "  Binary:   ${prefix}/bin/zig"
    echo "  Triplet:  ${prefix}/bin/${conda_triplet}-zig"
    echo "  Wrappers: ${prefix}/bin/${conda_triplet}-zig-{cc,c++,ar}"
    echo "  Stdlib:   ${prefix}/lib/zig/"
}

# === Install Native Compiler Implementation ===
# Installs ONLY the triplet-prefixed binary and stdlib (no wrappers, no activation)
# Used by zig_impl_$TG_ package
#
# Layout:
#   $PREFIX/bin/x86_64-conda-linux-gnu-zig       # Triplet-prefixed binary
#   $PREFIX/lib/zig/                             # Standard library
#   $PREFIX/doc/                                 # Documentation
#
install_native_compiler_impl() {
    local source_dir="$1"
    local prefix="$2"

    echo "=== Installing Native Compiler Implementation ==="

    local conda_triplet="${CONDA_TOOLCHAIN_HOST:-x86_64-conda-linux-gnu}"
    echo "Conda triplet: ${conda_triplet}"

    # Install triplet-prefixed binary (NOT unprefixed)
    mkdir -p "${prefix}/bin"
    if [[ -f "${source_dir}/zig" ]]; then
        cp "${source_dir}/zig" "${prefix}/bin/${conda_triplet}-zig"
    elif [[ -f "${source_dir}/bin/zig" ]]; then
        cp "${source_dir}/bin/zig" "${prefix}/bin/${conda_triplet}-zig"
    else
        echo "ERROR: Cannot find zig binary in ${source_dir}"
        return 1
    fi
    chmod +x "${prefix}/bin/${conda_triplet}-zig"

    # Install standard library
    mkdir -p "${prefix}/lib"
    if [[ -d "${source_dir}/lib/zig" ]]; then
        cp -r "${source_dir}/lib/zig" "${prefix}/lib/"
    elif [[ -d "${source_dir}/lib" ]]; then
        mkdir -p "${prefix}/lib/zig"
        cp -r "${source_dir}/lib/"* "${prefix}/lib/zig/"
    fi

    # Install documentation if present
    if [[ -d "${source_dir}/doc" ]]; then
        mkdir -p "${prefix}/doc"
        cp -r "${source_dir}/doc/"* "${prefix}/doc/"
    fi

    echo "Native compiler impl installed:"
    echo "  Binary:   ${prefix}/bin/${conda_triplet}-zig"
    echo "  Stdlib:   ${prefix}/lib/zig/"
    echo "  (NO activation scripts, NO wrappers - those go in zig_$TG_)"
}

# === Install Cross-Compiler Implementation ===
# Installs ONLY the native binary and stdlib for cross-compilation (no wrappers)
# Used by zig_impl_$TG_ package for cross-compilers
#
# Layout:
#   $PREFIX/bin/x86_64-conda-linux-gnu-zig       # Native binary (runs on host)
#   $PREFIX/lib/zig/                             # Standard library (universal)
#
install_cross_compiler_impl() {
    local source_dir="$1"
    local prefix="$2"

    echo "=== Installing Cross-Compiler Implementation ==="

    local native_triplet="${CONDA_TOOLCHAIN_BUILD:-x86_64-conda-linux-gnu}"
    echo "Native triplet: ${native_triplet}"

    # Install native zig binary (runs on build host)
    mkdir -p "${prefix}/bin"
    if [[ -f "${source_dir}/zig" ]]; then
        cp "${source_dir}/zig" "${prefix}/bin/${native_triplet}-zig"
    elif [[ -f "${source_dir}/bin/zig" ]]; then
        cp "${source_dir}/bin/zig" "${prefix}/bin/${native_triplet}-zig"
    else
        echo "ERROR: Cannot find zig binary in ${source_dir}"
        return 1
    fi
    chmod +x "${prefix}/bin/${native_triplet}-zig"

    # Install standard library (universal across targets)
    mkdir -p "${prefix}/lib"
    if [[ -d "${source_dir}/lib/zig" ]]; then
        cp -r "${source_dir}/lib/zig" "${prefix}/lib/"
    elif [[ -d "${source_dir}/lib" ]]; then
        mkdir -p "${prefix}/lib/zig"
        cp -r "${source_dir}/lib/"* "${prefix}/lib/zig/"
    fi

    echo "Cross-compiler impl installed:"
    echo "  Native:   ${prefix}/bin/${native_triplet}-zig"
    echo "  Stdlib:   ${prefix}/lib/zig/"
    echo "  (NO cross wrappers - those go in zig_$TG_)"
}

# === Install Zig Compiler (Dispatcher) ===
# Dispatches to native or cross-compiler installation based on BUILD_MODE and PKG_VARIANT
#
install_zig_compiler() {
    local source_dir="$1"
    local prefix="${2:-${PREFIX}}"

    # Ensure build mode is detected
    if [[ -z "${BUILD_MODE:-}" ]]; then
        detect_build_mode
    fi

    # Check if this is an impl package (set by recipe.yaml script env)
    if [[ "${PKG_VARIANT:-}" == "impl" ]]; then
        echo "Installing implementation package (zig_impl_$TG_)"
        case "${BUILD_MODE}" in
            native|cross-target)
                install_native_compiler_impl "${source_dir}" "${prefix}"
                ;;
            cross-compiler)
                install_cross_compiler_impl "${source_dir}" "${prefix}"
                ;;
            *)
                echo "ERROR: Unknown BUILD_MODE: ${BUILD_MODE}"
                return 1
                ;;
        esac
    else
        # Legacy path for non-impl packages (backwards compatibility)
        echo "Installing full package (legacy zig_$TG_ pattern)"
        case "${BUILD_MODE}" in
            native|cross-target)
                install_native_compiler "${source_dir}" "${prefix}"
                install_activation_scripts "${prefix}" ""
                install_wrapper_scripts "${prefix}"
                ;;
            cross-compiler)
                install_cross_compiler "${source_dir}" "${prefix}"
                ;;
            *)
                echo "ERROR: Unknown BUILD_MODE: ${BUILD_MODE}"
                return 1
                ;;
        esac
    fi

    echo "=== Zig Compiler Installation Complete ==="
}
