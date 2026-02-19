# === setup_zig_cc: Configure zig as C/C++ compiler for CMake ===
# Exports ZIG_CC, ZIG_CXX, ZIG_AR, etc. for use with CMake
#
# On Windows: Uses CMake semicolon-separated syntax (no wrapper scripts needed)
# On Unix: Creates wrapper scripts to filter out GCC-specific flags from conda

setup_zig_cc() {
    local zig="$1"
    local target="${2:-native}"
    local mcpu="${3:-baseline}"
    local wrapper_dir="${SRC_DIR}/zig-cc-wrappers"

    if [[ -z "${zig}" ]]; then
        echo "ERROR: setup_zig_cc requires zig binary path" >&2
        return 1
    fi

    mkdir -p "${wrapper_dir}"

    # Detect Windows (use :- to avoid unbound variable error with set -u)
    if [[ "${OSTYPE:-}" == "msys" ]] || [[ "${OSTYPE:-}" == "cygwin" ]] || [[ -n "${MSYSTEM:-}" ]] || [[ "${zig}" == *.exe ]]; then
        _setup_zig_cc_windows "${zig}" "${target}" "${mcpu}" "${wrapper_dir}"
    else
        _setup_zig_cc_unix "${zig}" "${target}" "${mcpu}" "${wrapper_dir}"
    fi

    # Clear conda's compiler flags - zig handles optimization internally
    unset CFLAGS CXXFLAGS LDFLAGS CPPFLAGS
    export CFLAGS="" CXXFLAGS="" LDFLAGS="" CPPFLAGS=""

    echo "=== setup_zig_cc: Configured zig compiler ==="
    echo "  ZIG_CC:     ${ZIG_CC}"
    echo "  ZIG_CXX:    ${ZIG_CXX}"
    echo "  ZIG_AR:     ${ZIG_AR}"
    echo "  Target:     ${target}"
    echo "  MCPU:       ${mcpu}"
}

# Windows: Use CMake semicolon-separated compiler syntax (like zig upstream)
_setup_zig_cc_windows() {
    local zig="$1"
    local target="$2"
    local mcpu="$3"
    local wrapper_dir="$4"

    # Ensure .exe extension on Windows (CMake requires full path with extension)
    if [[ "${zig}" != *.exe ]]; then
        if [[ -x "${zig}.exe" ]]; then
            zig="${zig}.exe"
        fi
    fi

    # CMake accepts semicolon-separated "compiler;arg1;arg2" format
    # This avoids needing wrapper scripts on Windows
    export ZIG_CC="${zig};cc;-target;${target};-mcpu=${mcpu}"
    export ZIG_CXX="${zig};c++;-target;${target};-mcpu=${mcpu}"
    export ZIG_ASM="${zig};cc;-target;${target};-mcpu=${mcpu}"
    export ZIG_AR="${zig};ar"
    export ZIG_RANLIB="${zig};ranlib"
    # RC compiler: try llvm-rc from build prefix, or leave unset (LLVM can build without it)
    local llvm_rc="${BUILD_PREFIX}/Library/bin/llvm-rc.exe"
    if [[ -x "${llvm_rc}" ]]; then
        export ZIG_RC="${llvm_rc}"
    else
        export ZIG_RC=""
    fi
}

# Unix (Linux/macOS): Create wrapper scripts with flag filtering
_setup_zig_cc_unix() {
    local zig="$1"
    local target="$2"
    local mcpu="$3"
    local wrapper_dir="$4"

    # Create zig-cc wrapper with flag filtering
    cat > "${wrapper_dir}/zig-cc" << EOF
#!/usr/bin/env bash
# Filter out GCC/GNU ld flags unsupported by zig's lld
args=()
i=0
argv=("\$@")
argc=\${#argv[@]}

while [[ \$i -lt \$argc ]]; do
    arg="\${argv[\$i]}"
    case "\$arg" in
        -Xlinker)
            next_i=\$((i + 1))
            if [[ \$next_i -lt \$argc ]]; then
                next_arg="\${argv[\$next_i]}"
                case "\$next_arg" in
                    -Bsymbolic-functions|-Bsymbolic|--color-diagnostics)
                        i=\$next_i ;;
                    *)
                        args+=("\$arg" "\$next_arg")
                        i=\$next_i ;;
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
        -Wl,-all_load|-Wl,-force_load,*) ;;
        -all_load|-force_load) ;;
        -Bsymbolic-functions|-Bsymbolic) ;;
        -march=*|-mtune=*|-ftree-vectorize) ;;
        -fstack-protector-strong|-fstack-protector|-fno-plt) ;;
        -fdebug-prefix-map=*) ;;
        *) args+=("\$arg") ;;
    esac
    ((i++))
done
exec "${zig}" cc -target ${target} -mcpu=${mcpu} "\${args[@]}"
EOF
    chmod +x "${wrapper_dir}/zig-cc"

    # Create zig-cxx wrapper (same filtering)
    cat > "${wrapper_dir}/zig-cxx" << EOF
#!/usr/bin/env bash
# Filter out GCC/GNU ld flags unsupported by zig's lld
args=()
i=0
argv=("\$@")
argc=\${#argv[@]}

while [[ \$i -lt \$argc ]]; do
    arg="\${argv[\$i]}"
    case "\$arg" in
        -Xlinker)
            next_i=\$((i + 1))
            if [[ \$next_i -lt \$argc ]]; then
                next_arg="\${argv[\$next_i]}"
                case "\$next_arg" in
                    -Bsymbolic-functions|-Bsymbolic|--color-diagnostics)
                        i=\$next_i ;;
                    *)
                        args+=("\$arg" "\$next_arg")
                        i=\$next_i ;;
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
        -Wl,-all_load|-Wl,-force_load,*) ;;
        -all_load|-force_load) ;;
        -Bsymbolic-functions|-Bsymbolic) ;;
        -march=*|-mtune=*|-ftree-vectorize) ;;
        -fstack-protector-strong|-fstack-protector|-fno-plt) ;;
        -fdebug-prefix-map=*) ;;
        *) args+=("\$arg") ;;
    esac
    ((i++))
done
exec "${zig}" c++ -target ${target} -mcpu=${mcpu} "\${args[@]}"
EOF
    chmod +x "${wrapper_dir}/zig-cxx"

    # Simple wrappers for ar, ranlib, asm, rc
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
}
