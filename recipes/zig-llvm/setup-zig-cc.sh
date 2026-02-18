# === setup_zig_cc: Create zig compiler wrappers ===
# Creates wrapper scripts for CMake that invoke zig cc/c++/ar/ranlib
# This eliminates the need for GCC/libstdc++ - zig uses libc++
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

    # Common flag filtering logic (filters GCC/GNU ld flags unsupported by zig's lld)
    local filter_logic='
args=()
i=0
argv=("$@")
argc=${#argv[@]}

while [[ $i -lt $argc ]]; do
    arg="${argv[$i]}"
    case "$arg" in
        -Xlinker)
            next_i=$((i + 1))
            if [[ $next_i -lt $argc ]]; then
                next_arg="${argv[$next_i]}"
                case "$next_arg" in
                    -Bsymbolic-functions|-Bsymbolic|--color-diagnostics)
                        i=$next_i ;;
                    *)
                        args+=("$arg" "$next_arg")
                        i=$next_i ;;
                esac
            fi
            ;;
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
        -Bsymbolic-functions|-Bsymbolic) ;;
        -march=*|-mtune=*|-ftree-vectorize) ;;
        -fstack-protector-strong|-fstack-protector|-fno-plt) ;;
        -fdebug-prefix-map=*) ;;
        *) args+=("$arg") ;;
    esac
    ((i++))
done
'

    cat > "${wrapper_dir}/zig-cc" << WRAPPER_EOF
#!/usr/bin/env bash
${filter_logic}
exec "${zig}" cc -target ${target} -mcpu=${mcpu} "\${args[@]}"
WRAPPER_EOF
    chmod +x "${wrapper_dir}/zig-cc"

    cat > "${wrapper_dir}/zig-cxx" << WRAPPER_EOF
#!/usr/bin/env bash
${filter_logic}
exec "${zig}" c++ -target ${target} -mcpu=${mcpu} "\${args[@]}"
WRAPPER_EOF
    chmod +x "${wrapper_dir}/zig-cxx"

    cat > "${wrapper_dir}/zig-ar" << EOF
#!/usr/bin/env bash
exec "${zig}" ar "\$@"
EOF
    chmod +x "${wrapper_dir}/zig-ar"

    cat > "${wrapper_dir}/zig-ranlib" << EOF
#!/usr/bin/env bash
exec "${zig}" ranlib "\$@"
EOF
    chmod +x "${wrapper_dir}/zig-ranlib"

    cat > "${wrapper_dir}/zig-asm" << EOF
#!/usr/bin/env bash
exec "${zig}" cc -target ${target} -mcpu=${mcpu} "\$@"
EOF
    chmod +x "${wrapper_dir}/zig-asm"

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
    unset CFLAGS CXXFLAGS LDFLAGS CPPFLAGS
    export CFLAGS="" CXXFLAGS="" LDFLAGS="" CPPFLAGS=""

    echo "=== setup_zig_cc: Created zig compiler wrappers ==="
    echo "  ZIG_CC:     ${ZIG_CC}"
    echo "  ZIG_CXX:    ${ZIG_CXX}"
    echo "  Target:     ${target}"
    echo "  MCPU:       ${mcpu}"
}
