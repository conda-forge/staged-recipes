#!/usr/bin/env bash
# =============================================================================
# qemu-user-patched: Unified build script with variant support
# =============================================================================
# Environment variables:
#   CONDA_QEMU_TARGET:  Target architecture (aarch64, ppc64le, s390x, riscv64)
#   CONDA_QEMU_VARIANT: Package variant (user, execve, zig)
# =============================================================================

set -euxo pipefail
IFS=$'\n\t'

if [[ ${BASH_VERSINFO[0]} -lt 5 || (${BASH_VERSINFO[0]} -eq 5 && ${BASH_VERSINFO[1]} -lt 2) ]]; then
  echo "re-exec with conda bash..."
  if [[ -x "${BUILD_PREFIX}/bin/bash" ]]; then
    exec "${BUILD_PREFIX}/bin/bash" "$0" "$@"
  else
    echo "ERROR: Could not find conda bash at ${BUILD_PREFIX}/bin/bash"
    exit 1
  fi
fi

source "${RECIPE_DIR}/functions.sh"

# --- Configuration ---

install_dir="${PREFIX}"
qemu_arch="${CONDA_QEMU_TARGET:-aarch64}"
qemu_variant="${CONDA_QEMU_VARIANT:-execve}"

echo "=== Building qemu-${qemu_variant}-${qemu_arch} ==="

# --- Step 1: Apply variant-specific patches ---

_apply_variant_patches "${SRC_DIR}/qemu_source" "${qemu_variant}"

# --- Step 1b: Patch zig wrapper for -Xlinker auto-LLD promotion ---
# Published zig _18 only scans -Wl, prefixed flags for LLD promotion.
# QEMU's meson passes --dynamic-list via -Xlinker, not -Wl,. Patch the
# installed wrapper until zig ships with the -Xlinker fix.
_zig_common="${BUILD_PREFIX}/share/zig/wrappers/_zig-cc-common.sh"
if ! grep -q '_xlinker_next' "${_zig_common}"; then
  sed -i '/_use_lld=0/a\
_xlinker_next=0' "${_zig_common}"
  sed -i '/for _a in "\$@"; do/a\
    # Handle -Xlinker <arg> pairs: check the arg after -Xlinker for LLD triggers\
    if (( _xlinker_next )); then\
        _xlinker_next=0\
        case "$_a" in\
            --dynamic-list|--dynamic-list=*|--version-script|--version-script=*) _use_lld=1; break ;;\
            --gc-sections|--no-gc-sections|--build-id|--build-id=*) _use_lld=1; break ;;\
            --allow-shlib-undefined|--no-allow-shlib-undefined) _use_lld=1; break ;;\
            -exported_symbols_list|-exported_symbols_list,*) _use_lld=1; break ;;\
            -unexported_symbols_list|-unexported_symbols_list,*) _use_lld=1; break ;;\
            -all_load|-force_load|-force_load,*) _use_lld=1; break ;;\
        esac\
        continue\
    fi' "${_zig_common}"
  sed -i '/case "\$_a" in/,/^[[:space:]]*esac/{
    /case "\$_a" in/a\
        -Xlinker) _xlinker_next=1 ;;
  }' "${_zig_common}"
  echo "=== Patched zig wrapper for -Xlinker auto-LLD promotion ==="
fi

# --- Step 2: Build and install QEMU ---

# QEMU configure detects host_os via check_define __linux__ using CC.
# zig-cc's preprocessor doesn't define __linux__, so force it.
export host_os=linux

# zig cc doesn't understand -Xlinker; translate to -Wl, form.
# (meson passes --dynamic-list etc. via -Xlinker, not -Wl,)
cat > "${SRC_DIR}/_zig_cc" <<WRAPPER
#!/usr/bin/env bash
args=()
while [[ \$# -gt 0 ]]; do
    if [[ "\$1" == "-Xlinker" ]] && [[ \$# -gt 1 ]]; then
        args+=("-Wl,\$2")
        shift 2
    else
        args+=("\$1")
        shift
    fi
done
exec "${ZIG_CC}" "\${args[@]}"
WRAPPER
chmod +x "${SRC_DIR}/_zig_cc"
export CC="${SRC_DIR}/_zig_cc"
export AR="${ZIG_AR}"
export RANLIB="${ZIG_RANLIB}"
_build_install_qemu "${SRC_DIR}/_conda-build-${qemu_variant}" "${install_dir}" "${qemu_variant}"

# --- Step 3: Install variant-specific files ---

case "${qemu_variant}" in
  zig)
    echo "=== qemu-zig-${qemu_arch}: No activation scripts ==="
    ;;

  *)
    echo "ERROR: Unknown variant: ${qemu_variant}"
    exit 1
    ;;
esac

echo "=== Build complete: qemu-${qemu_variant}-${qemu_arch} ==="
