# ZIG CC COMPILER WRAPPERS
# Creates wrapper scripts for CMake that invoke zig cc/c++/ar/ranlib
# This eliminates the need for GCC/libstdc++ - zig uses libc++
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

    # Common flag filtering logic (shared between zig-cc and zig-cxx)
    # Filters out GCC/GNU ld-specific flags that zig's lld-based linker doesn't support
    local filter_logic='
args=()
i=0
argv=("$@")
argc=${#argv[@]}

while [[ $i -lt $argc ]]; do
    arg="${argv[$i]}"

    case "$arg" in
        # Handle -Xlinker <arg> pairs - check if next arg should be filtered
        -Xlinker)
            next_i=$((i + 1))
            if [[ $next_i -lt $argc ]]; then
                next_arg="${argv[$next_i]}"
                case "$next_arg" in
                    -Bsymbolic-functions|-Bsymbolic|--color-diagnostics)
                        i=$next_i ;;  # Skip both -Xlinker and its argument
                    *)
                        args+=("$arg" "$next_arg")
                        i=$next_i ;;
                esac
            fi
            ;;

        # Unsupported -Wl, flags (zig uses lld, not GNU ld)
        -Wl,-rpath-link|-Wl,-rpath-link,*|-Wl,--disable-new-dtags) ;;
        -Wl,--allow-shlib-undefined|-Wl,--no-allow-shlib-undefined) ;;
        -Wl,-Bsymbolic-functions|-Wl,-Bsymbolic) ;;
        -Wl,--color-diagnostics) ;;
        -Wl,-soname|-Wl,-soname,*) ;;
        -Wl,--version-script|-Wl,--version-script,*) ;;
        -Wl,-z,defs|-Wl,-z,nodelete|-Wl,-z,*) ;;
        -Wl,--as-needed|-Wl,--no-as-needed) ;;
        -Wl,-O*) ;;
        -Wl,--gc-sections|-Wl,--no-gc-sections) ;;
        -Wl,--build-id|-Wl,--build-id=*) ;;

        # Bare linker flags
        -Bsymbolic-functions|-Bsymbolic) ;;

        # GCC-specific flags
        -march=*|-mtune=*|-ftree-vectorize) ;;
        -fstack-protector-strong|-fstack-protector|-fno-plt) ;;
        -fdebug-prefix-map=*) ;;

        # Pass through everything else
        *) args+=("$arg") ;;
    esac

    ((i++))
done
'

    # zig-cc wrapper
    cat > "${wrapper_dir}/zig-cc" << WRAPPER_EOF
#!/usr/bin/env bash
${filter_logic}
exec "${zig}" cc -target ${target} -mcpu=${mcpu} "\${args[@]}"
WRAPPER_EOF
    chmod +x "${wrapper_dir}/zig-cc"

    # zig-cxx wrapper (same filtering)
    cat > "${wrapper_dir}/zig-cxx" << WRAPPER_EOF
#!/usr/bin/env bash
${filter_logic}
exec "${zig}" c++ -target ${target} -mcpu=${mcpu} "\${args[@]}"
WRAPPER_EOF
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
exec "${zig}" cc -target ${target} -mcpu=${mcpu} "\$@"
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
}
