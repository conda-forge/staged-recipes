
# Function to run a command, log its output, and increment log index
run_and_log() {
  local _logname="$1"
  shift
  local cmd=("$@")

  # Create log directory if it doesn't exist
  mkdir -p "${SRC_DIR}/_logs"

  echo " ";echo "|";echo "|";echo "|";echo "|"
  echo "Running: ${cmd[*]}"
  local start_time=$(date +%s)
  local exit_status_file=$(mktemp)
  # Run the command in a subshell to prevent set -e from terminating
  (
    # Temporarily disable errexit in this subshell
    set +e
    "${cmd[@]}" > "${SRC_DIR}/_logs/${_log_index}_${_logname}.log" 2>&1
    echo $? > "$exit_status_file"
  ) &
  local cmd_pid=$!
  local tail_counter=0

  # Periodically flush and show progress
  while kill -0 $cmd_pid 2>/dev/null; do
    sync
    echo -n "."
    sleep 5
    let "tail_counter += 1"

    if [ $tail_counter -ge 22 ]; then
      echo "."
      tail -5 "${SRC_DIR}/_logs/${_log_index}_${_logname}.log"
      tail_counter=0
    fi
  done

  wait $cmd_pid || true  # Use || true to prevent set -e from triggering
  local end_time=$(date +%s)
  local duration=$((end_time - start_time))
  local exit_code=$(cat "$exit_status_file")
  rm "$exit_status_file"

  echo "."
  echo "─────────────────────────────────────────"
  printf "Command: %s\n" "${cmd[*]} in ${duration}s"
  echo "Exit code: $exit_code"
  echo "─────────────────────────────────────────"

  # Show more context on failure
  if [[ $exit_code -ne 0 ]]; then
    echo "COMMAND FAILED - Last 50 lines of log:"
    tail -50 "${SRC_DIR}/_logs/${_log_index}_${_logname}.log"
  else
    echo "COMMAND SUCCEEDED - Last 20 lines of log:"
    tail -20 "${SRC_DIR}/_logs/${_log_index}_${_logname}.log"
  fi

  echo "─────────────────────────────────────────"
  echo "Full log: ${SRC_DIR}/_logs/${_log_index}_${_logname}.log"
  echo "|";echo "|";echo "|";echo "|"

  let "_log_index += 1"
  return $exit_code
}

# ==============================================================================
# PLATFORM DETECTION
# ==============================================================================

# Detect platform-specific configuration and set global variables
#
# Sets global variables:
#   OS_TYPE        - "linux" or "darwin"
#   LIB_EXT        - "so" or "dylib"
#   GHC_OS_SUFFIX  - "-unknown-linux-gnu" or "darwin"
#   USE_SYSROOT    - "true" or "false"
#
# Parameters:
#   $1 - platform: Target platform (e.g., "linux-64", "osx-64", "osx-arm64")
#
# Usage:
#   detect_platform_config "${target_platform}"
#   echo "Building for ${OS_TYPE} with library extension ${LIB_EXT}"
#
detect_platform_config() {
  local platform="$1"

  if [[ "${platform}" == linux-* ]]; then
    export OS_TYPE="linux"
    export LIB_EXT="so"
    export GHC_OS_SUFFIX="-unknown-linux-gnu"
    export USE_SYSROOT="true"
  elif [[ "${platform}" == osx-* ]]; then
    export OS_TYPE="darwin"
    export LIB_EXT="dylib"
    export GHC_OS_SUFFIX="darwin"
    export USE_SYSROOT="false"
  else
    echo "ERROR: Unsupported platform: ${platform}" >&2
    return 1
  fi

  echo "=== Platform Configuration ===" >&2
  echo "  Target platform: ${platform}" >&2
  echo "  OS type: ${OS_TYPE}" >&2
  echo "  Library extension: ${LIB_EXT}" >&2
  echo "  GHC OS suffix: ${GHC_OS_SUFFIX}" >&2
  echo "  Use sysroot: ${USE_SYSROOT}" >&2
  echo "==============================" >&2
}

# ==============================================================================
# ARCHITECTURE-SPECIFIC COMPILE FLAGS
# ==============================================================================

# Generate architecture-specific compile and link flags for cross-compilation
#
# Sets global variables:
#   CROSS_CFLAGS
#   CROSS_CXXFLAGS
#   CROSS_CPPFLAGS
#   CROSS_LDFLAGS
#
# Parameters:
#   $1 - target_arch: Target architecture (aarch64, powerpc64le, x86_64)
#   $2 - os_type: Operating system type (linux, darwin)
#   $3 - conda_target: Conda target triplet (for sysroot path on Linux)
#
# Usage:
#   get_arch_compile_flags "${target_arch}" "${OS_TYPE}" "${conda_target}"
#
get_arch_compile_flags() {
  local target_arch="$1"
  local os_type="$2"
  local conda_target="${3:-}"

  echo "=== Configuring architecture flags ===" >&2
  echo "  Target architecture: ${target_arch}" >&2
  echo "  OS type: ${os_type}" >&2

  if [[ "${os_type}" == "linux" ]]; then
    # Linux: Architecture-specific flags based on target
    if [[ "${target_arch}" == "aarch64" ]]; then
      CROSS_CFLAGS=$(echo "$CFLAGS" | sed 's/-march=[^ ]*/-march=armv8-a/g' | sed 's/-mtune=[^ ]*/-mtune=generic/g' | sed 's/  */ /g' | sed 's/^ *//' | sed 's/ *$//')
      CROSS_CXXFLAGS=$(echo "$CXXFLAGS" | sed 's/-march=[^ ]*/-march=armv8-a/g' | sed 's/-mtune=[^ ]*/-mtune=generic/g' | sed 's/  */ /g' | sed 's/^ *//' | sed 's/ *$//')
      CROSS_CPPFLAGS=$(echo "$CPPFLAGS" | sed 's/-march=[^ ]*/-march=armv8-a/g' | sed 's/-mtune=[^ ]*/-mtune=generic/g' | sed 's/  */ /g' | sed 's/^ *//' | sed 's/ *$//')
    elif [[ "${target_arch}" == "powerpc64le" ]]; then
      CROSS_CFLAGS=$(echo "$CFLAGS" | sed 's/-march=[^ ]*/-mcpu=power8/g' | sed 's/-mtune=[^ ]*/-mtune=power8/g' | sed 's/  */ /g' | sed 's/^ *//' | sed 's/ *$//')
      CROSS_CXXFLAGS=$(echo "$CXXFLAGS" | sed 's/-march=[^ ]*/-mcpu=power8/g' | sed 's/-mtune=[^ ]*/-mtune=power8/g' | sed 's/  */ /g' | sed 's/^ *//' | sed 's/ *$//')
      CROSS_CPPFLAGS=$(echo "$CPPFLAGS" | sed 's/-march=[^ ]*/-mcpu=power8/g' | sed 's/-mtune=[^ ]*/-mtune=power8/g' | sed 's/  */ /g' | sed 's/^ *//' | sed 's/ *$//')
    else
      # x86_64
      CROSS_CFLAGS=$(echo "$CFLAGS" | sed 's/-march=[^ ]*/-march=nocona/g' | sed 's/-mtune=[^ ]*/-mtune=haswell/g' | sed 's/  */ /g' | sed 's/^ *//' | sed 's/ *$//')
      CROSS_CXXFLAGS=$(echo "$CXXFLAGS" | sed 's/-march=[^ ]*/-march=nocona/g' | sed 's/-mtune=[^ ]*/-mtune=haswell/g' | sed 's/  */ /g' | sed 's/^ *//' | sed 's/ *$//')
      CROSS_CPPFLAGS=$(echo "$CPPFLAGS" | sed 's/-march=[^ ]*/-march=nocona/g' | sed 's/-mtune=[^ ]*/-mtune=haswell/g' | sed 's/  */ /g' | sed 's/^ *//' | sed 's/ *$//')
    fi

    # Add sysroot for Linux
    CROSS_CFLAGS="${CROSS_CFLAGS} --sysroot=${BUILD_PREFIX}/${conda_target}/sysroot"
    CROSS_CPPFLAGS="${CROSS_CPPFLAGS} --sysroot=${BUILD_PREFIX}/${conda_target}/sysroot"
    CROSS_CXXFLAGS="${CROSS_CXXFLAGS} --sysroot=${BUILD_PREFIX}/${conda_target}/sysroot"
    CROSS_LDFLAGS="-L${BUILD_PREFIX}/${conda_target}/lib -L${BUILD_PREFIX}/${conda_target}/sysroot/usr/lib ${LDFLAGS:-}"

  elif [[ "${os_type}" == "darwin" ]]; then
    # macOS: Static flags (architecture-independent)
    CROSS_CFLAGS="-ftree-vectorize -fPIC -fstack-protector-strong -O2 -pipe -isystem $PREFIX/include"
    CROSS_CXXFLAGS="-ftree-vectorize -fPIC -fstack-protector-strong -O2 -pipe -stdlib=libc++ -fvisibility-inlines-hidden -fmessage-length=0 -isystem $PREFIX/include"
    CROSS_CPPFLAGS="-D_FORTIFY_SOURCE=2 -isystem $PREFIX/include -mmacosx-version-min=11.0"
    CROSS_LDFLAGS=""
  else
    echo "ERROR: Unsupported OS type: ${os_type}" >&2
    return 1
  fi

  export CROSS_CFLAGS
  export CROSS_CXXFLAGS
  export CROSS_CPPFLAGS
  export CROSS_LDFLAGS

  echo "  CROSS_CFLAGS: ${CROSS_CFLAGS}" >&2
  echo "  CROSS_CXXFLAGS: ${CROSS_CXXFLAGS}" >&2
  echo "  CROSS_CPPFLAGS: ${CROSS_CPPFLAGS}" >&2
  echo "  CROSS_LDFLAGS: ${CROSS_LDFLAGS}" >&2
  echo "==============================" >&2
}

# ==============================================================================
# CROSS ENVIRONMENT CREATION
# ==============================================================================

# Create conda environment for cross-compilation target libraries
#
# Sets global variables:
#   CROSS_ENV_PATH
#   CROSS_LIB_DIR
#   CROSS_INCLUDE_DIR
#
# Parameters:
#   $1 - cross_target_platform: Target platform for cross environment
#
# Usage:
#   create_cross_environment "${cross_target_platform}"
#
create_cross_environment() {
  local cross_target_platform="$1"

  echo "=== Creating cross environment ===" >&2
  echo "  Target platform: ${cross_target_platform}" >&2

  conda create -y \
      -n cross_env \
      --platform "${cross_target_platform}" \
      -c conda-forge \
      gmp \
      libffi \
      libiconv \
      ncurses

  # Allow conda to settle
  sleep 10

  # Get the environment path and set up library paths
  CROSS_ENV_PATH=$(conda info --envs | grep cross_env | awk '{print $2}')
  export CROSS_LIB_DIR="${CROSS_ENV_PATH}/lib"
  export CROSS_INCLUDE_DIR="${CROSS_ENV_PATH}/include"

  echo "  Cross environment: ${CROSS_ENV_PATH}" >&2
  echo "  Cross libraries: ${CROSS_LIB_DIR}" >&2
  echo "  Cross headers: ${CROSS_INCLUDE_DIR}" >&2
  echo "==============================" >&2
}

# ==============================================================================
# GHC CONFIGURE
# ==============================================================================

# Configure GHC for cross-compilation with platform-specific settings
#
# Sets global variables:
#   AR_STAGE0
#   CC_STAGE0
#   LD_STAGE0
#
# Parameters:
#   $1 - os_type: Operating system type (linux, darwin)
#   $2 - ghc_target: GHC target triplet
#   $3 - conda_host: Conda host triplet
#   $4 - conda_target: Conda target triplet
#
# Usage:
#   configure_ghc "${OS_TYPE}" "${ghc_target}" "${conda_host}" "${conda_target}"
#
configure_ghc() {
  local os_type="$1"
  local ghc_target="$2"
  local conda_host="$3"
  local conda_target="$4"

  echo "=== Configuring GHC ===" >&2
  echo "  OS type: ${os_type}" >&2
  echo "  GHC target: ${ghc_target}" >&2
  echo "  Conda host: ${conda_host}" >&2
  echo "  Conda target: ${conda_target}" >&2

  # Stage0 tools (build machine)
  if [[ "${os_type}" == "darwin" ]]; then
    export AR_STAGE0=$(find "${BUILD_PREFIX}" -name llvm-ar | head -1)
  else
    export AR_STAGE0="${BUILD_PREFIX}/bin/${conda_host}-ar"
  fi
  export CC_STAGE0="${CC_FOR_BUILD}"
  export LD_STAGE0="${BUILD_PREFIX}/bin/${conda_host}-ld"

  echo "  AR_STAGE0: ${AR_STAGE0}" >&2
  echo "  CC_STAGE0: ${CC_STAGE0}" >&2
  echo "  LD_STAGE0: ${LD_STAGE0}" >&2

  # Platform-specific --target
  # Linux: Use ghc_target (stripped to just arch-unknown-linux-gnu)
  # macOS: Use conda_target (full triplet with darwin version for proper path generation)
  local configure_target
  if [[ "${os_type}" == "darwin" ]]; then
    configure_target="${conda_target}"
  else
    configure_target="${ghc_target}"
  fi

  echo "  Configure --target: ${configure_target}" >&2

  # Common system configuration
  local SYSTEM_CONFIG=(
    --target="${configure_target}"
    --prefix="${PREFIX}"
  )

  # Common configure arguments
  local CONFIGURE_ARGS=(
    --with-system-libffi=yes
    --with-curses-includes="${CROSS_INCLUDE_DIR}"
    --with-curses-libraries="${CROSS_LIB_DIR}"
    --with-ffi-includes="${CROSS_INCLUDE_DIR}"
    --with-ffi-libraries="${CROSS_LIB_DIR}"
    --with-gmp-includes="${CROSS_INCLUDE_DIR}"
    --with-gmp-libraries="${CROSS_LIB_DIR}"
    --with-iconv-includes="${CROSS_INCLUDE_DIR}"
    --with-iconv-libraries="${CROSS_LIB_DIR}"
    
    ac_cv_path_AR="${BUILD_PREFIX}/bin/${conda_target}-ar"
    ac_cv_path_AS="${BUILD_PREFIX}/bin/${conda_target}-as"
    ac_cv_path_CC="${BUILD_PREFIX}/bin/${conda_target}-clang"
    ac_cv_path_CXX="${BUILD_PREFIX}/bin/${conda_target}-clang++"
    ac_cv_path_LD="${BUILD_PREFIX}/bin/${conda_target}-ld"
    ac_cv_path_NM="${BUILD_PREFIX}/bin/${conda_target}-nm"
    ac_cv_path_RANLIB="${BUILD_PREFIX}/bin/${conda_target}-ranlib"
    ac_cv_path_LLC="${BUILD_PREFIX}/bin/${conda_target}-llc"
    ac_cv_path_OPT="${BUILD_PREFIX}/bin/${conda_target}-opt"
    
    CFLAGS="${CROSS_CFLAGS}"
    CPPFLAGS="${CROSS_CPPFLAGS}"
    CXXFLAGS="${CROSS_CXXFLAGS}"
    LDFLAGS="${CROSS_LDFLAGS:-}"
  )

  # Platform-specific ac_cv variables and flags
  if [[ "${os_type}" == "linux" ]]; then
    # Linux: Use ac_cv_path_* for all tools
    CONFIGURE_ARGS+=(
      ac_cv_path_OBJDUMP="${BUILD_PREFIX}/bin/${conda_target}-objdump"
    )

    # Linux-specific exports before configure
    export ac_cv_func_statx=no
    export ac_cv_have_decl_statx=no
    export ac_cv_lib_ffi_ffi_call=yes
  fi

  echo "  Running ./configure..." >&2
  run_and_log "configure" ./configure -v "${SYSTEM_CONFIG[@]}" "${CONFIGURE_ARGS[@]}" || {
    cat config.log
    return 1
  }

  echo "=== GHC configured successfully ===" >&2
}

# Function to set the conda ar/ranlib for OSX
set_macos_conda_ar_ranlib() {
  local settings_file="$1"
  local toolchain="${2:-x86_64-apple-darwin13.4.0}"

  if [[ -f "$settings_file" ]]; then
    if [[ "$(basename "${settings_file}")" == "default."* ]]; then
      # Use LLVM ar instead of GNU ar for compatibility with Apple ld64
      perl -i -pe 's#(arMkArchive\s*=\s*).*#$1Program {prgPath = "llvm-ar", prgFlags = ["qcs"]}#g' "${settings_file}"
      perl -i -pe 's#((arIsGnu|arSupportsAtFile)\s*=\s*).*#$1False#g' "${settings_file}"
      perl -i -pe 's#(arNeedsRanlib\s*=\s*).*#$1False#g' "${settings_file}"
      perl -i -pe 's#(tgtRanlib\s*=\s*).*#$1Nothing#g' "${settings_file}"
    else
      # Use LLVM ar instead of GNU ar for compatibility with Apple ld64
      perl -i -pe 's#("ar command", ")[^"]*#$1llvm-ar#g' "${settings_file}"
      perl -i -pe 's#("ar flags", ")[^"]*#$1qcs#g' "${settings_file}"
      perl -i -pe "s#(\"(clang|llc|opt|ranlib) command\", \")[^\"]*#\$1${toolchain}-\$2#g" "${settings_file}"
    fi
  else
    echo "Error: $settings_file not found!"
    exit 1
  fi
}

update_settings_link_flags() {
  local settings_file="$1"
  local toolchain="${2:-$CONDA_TOOLCHAIN_HOST}"
  
  if [[ "${target_platform}" == "linux-"* ]]; then
    perl -pi -e 's#(C compiler flags", "[^"]*)#$1 -Wno-strict-prototypes#' "${settings_file}"
    perl -pi -e 's#(C\+\+ compiler flags", "[^"]*)#$1 -Wno-strict-prototypes#' "${settings_file}"

    perl -pi -e "s#(C compiler link flags\", \"[^\"]*)#\$1 -Wl,-L${BUILD_PREFIX}/lib -Wl,-L${PREFIX}/lib -Wl,-rpath,${BUILD_PREFIX}/lib -Wl,-rpath,${PREFIX}/lib#" "${settings_file}"
    perl -pi -e "s#(ld flags\", \"[^\"]*)#\$1 -L${BUILD_PREFIX}/lib -L${PREFIX}/lib -rpath ${BUILD_PREFIX}/lib -rpath ${PREFIX}/lib#" "${settings_file}"

  elif [[ "${target_platform}" == "osx-"* ]]; then
    perl -pi -e "s#(C compiler link flags\", \"[^\"]*)#\$1 -Wl,-L${PREFIX}/lib -Wl,-liconv -Wl,-L${PREFIX}/lib/ghc-${PKG_VERSION}/lib -Wl,-liconv_compat#" "${settings_file}"
    perl -pi -e "s#(ld flags\", \"[^\"]*)#\$1 -L${PREFIX}/lib -liconv -L${PREFIX}/lib/ghc-${PKG_VERSION}/lib -liconv_compat#" "${settings_file}"
  fi
  
  perl -pi -e "s#\"[/\w\-]*?(ar|clang|clang\+\+|ld|ranlib|llc|objdump|opt)\"#\"${toolchain}-\$1\"#" "${settings_file}"
}

# ==============================================================================
# HADRIAN DEPENDENCY BUILDER
# ==============================================================================

# Build Hadrian and its dependencies with correct toolchain for build machine
#
# CRITICAL: Hadrian is a BUILD TOOL that runs on the build machine (x86_64),
# NOT on the target machine (aarch64/ppc64le). Therefore:
# - MUST use BUILD machine compilers (CC_STAGE0, not CC)
# - MUST use BUILD machine CFLAGS (x86_64, not target flags)
# - MUST NOT be affected by target architecture environment variables
#
# Reference: CLAUDE.md "CRITICAL #1: Directory Package Configure Failure"
#
# Exports:
#   HADRIAN_BIN - Path to the built hadrian executable
#
# Returns:
#   stdout - Path to hadrian executable (for command substitution)
#
# Usage:
#   # Option 1: Use exported variable
#   build_hadrian_cross "${GHC}" "${AR_STAGE0}" "${CC_STAGE0}" "${LD_STAGE0}"
#   "${HADRIAN_BIN}" --version
#
#   # Option 2: Capture return value
#   HADRIAN_BUILD=$(build_hadrian_cross "${GHC}" "${AR_STAGE0}" "${CC_STAGE0}" "${LD_STAGE0}")
#   "${HADRIAN_BUILD}" --version
#
#   # With custom CFLAGS for build machine:
#   build_cflags="--sysroot=... -march=nocona ..."
#   HADRIAN_BUILD=$(build_hadrian_cross "${GHC}" "${AR_STAGE0}" "${CC_STAGE0}" "${LD_STAGE0}" "${build_cflags}")
#
# Parameters:
#   $1 - ghc_path: Path to bootstrap GHC (must run on build machine)
#   $2 - ar_stage0: Path to ar for build machine
#   $3 - cc_stage0: Path to C compiler for build machine
#   $4 - ld_stage0: Path to linker for build machine
#   $5 - extra_cflags: Override CFLAGS for build machine (optional)
#   $6 - extra_ldflags: Override LDFLAGS for build machine (optional)
#
build_hadrian_cross() {
  local ghc_path="$1"
  local ar_stage0="$2"
  local cc_stage0="$3"
  local ld_stage0="$4"
  local extra_cflags="${5:-}"
  local extra_ldflags="${6:-}"

  echo "=== Building Hadrian with dependencies ===" >&2
  echo "  GHC: ${ghc_path}" >&2
  echo "  AR: ${ar_stage0}" >&2
  echo "  CC: ${cc_stage0}" >&2
  echo "  LD: ${ld_stage0}" >&2

  # Silence pushd output to avoid polluting command substitution
  pushd "${SRC_DIR}/hadrian" >/dev/null || return 1

  # CRITICAL: Override CFLAGS/LDFLAGS if provided
  # This prevents target architecture flags from contaminating Hadrian build
  if [[ -n "$extra_cflags" ]]; then
    echo "  Overriding CFLAGS for build machine:" >&2
    echo "    ${extra_cflags}" >&2
    cflags="$extra_cflags"
  fi

  if [[ -n "$extra_ldflags" ]]; then
    echo "  Overriding LDFLAGS for build machine:" >&2
    echo "    ${extra_ldflags}" >&2
    ldflags="$extra_ldflags"
  fi

  CFLAGS="${extra_cflags:-${CFLAGS}}" LDFLAGS="${extra_ldflags:-${LDFLAGS}}" "${CABAL}" v2-build \
    --with-ar="${ar_stage0}" \
    --with-gcc="${cc_stage0}" \
    --with-ghc="${ghc_path}" \
    --with-ld="${ld_stage0}" \
    -j \
    hadrian \
    > "${SRC_DIR}/cabal-verbose.log" 2>&1
    # --enable-shared \
    # --enable-executable-dynamic \
    # "${hadrian_deps[@]}" \

  local exit_code=$?

  # Silence popd output to avoid polluting command substitution
  popd >/dev/null || return 1

  if [[ $exit_code -ne 0 ]]; then
    echo "=== Cabal build FAILED with exit code ${exit_code} ===" >&2
    cat "${SRC_DIR}"/cabal-verbose.log >&2
    return 1
  fi

  # Find hadrian binary location - return FULL ABSOLUTE path
  local hadrian_path
  local search_dir

  # Ensure SRC_DIR is actually set and is an absolute path
  if [[ -z "${SRC_DIR}" ]]; then
    echo "=== ERROR: SRC_DIR is not set ===" >&2
    return 1
  fi

  # Get absolute path to search directory
  search_dir="$(cd "${SRC_DIR}/hadrian" 2>/dev/null && pwd)" || {
    echo "=== ERROR: Cannot access ${SRC_DIR}/hadrian directory ===" >&2
    return 1
  }

  echo "   Searching for hadrian in: ${search_dir}" >&2

  # Note: -executable flag not supported on macOS find, use -perm instead
  if [[ "$(uname)" == "Darwin" ]]; then
    hadrian_path=$(find "${search_dir}" -type f -name hadrian -perm +111 2>/dev/null | head -1)
  else
    hadrian_path=$(find "${search_dir}" -type f -name hadrian -executable 2>/dev/null | head -1)
  fi

  # Fallback: just find by name if executable search failed
  if [[ -z "$hadrian_path" ]]; then
    hadrian_path=$(find "${search_dir}" -type f -name hadrian 2>/dev/null | head -1)
  fi

  if [[ -z "$hadrian_path" || ! -f "$hadrian_path" ]]; then
    echo "=== ERROR: Could not find hadrian binary ===" >&2
    echo "Searched in: ${search_dir}" >&2
    echo "Files matching 'hadrian*':" >&2
    find "${search_dir}" -type f -name "hadrian*" 2>&1 | head -10 >&2
    echo "Directory contents:" >&2
    ls -la "${search_dir}/dist-newstyle/build/" 2>&1 | head -20 >&2
    return 1
  fi

  # Ensure path is absolute and doesn't contain variable references
  if [[ "${hadrian_path}" == *'$'* ]]; then
    echo "=== ERROR: Hadrian path contains variable reference: ${hadrian_path} ===" >&2
    echo "This indicates a build system issue" >&2
    return 1
  fi

  # Convert to absolute path if somehow it's relative
  hadrian_path="$(cd "$(dirname "${hadrian_path}")" 2>/dev/null && pwd)/$(basename "${hadrian_path}")" || {
    echo "   WARNING: Failed to convert to absolute path, using as-is" >&2
  }

  # Ensure it's executable
  if [[ ! -x "$hadrian_path" ]]; then
    echo "=== WARNING: Hadrian found but not executable, fixing permissions ===" >&2
    chmod +x "$hadrian_path" || {
      echo "=== ERROR: Cannot make hadrian executable ===" >&2
      return 1
    }
  fi

  # Export for convenience
  export HADRIAN_BIN="${hadrian_path}"

  echo "=== Hadrian build completed successfully ===" >&2
  echo "   Hadrian binary: ${hadrian_path}" >&2

  # Test that it actually works
  if "${hadrian_path}" --version >&2 2>&1; then
    echo "   Hadrian version check: OK" >&2
  else
    echo "=== ERROR: Hadrian binary exists but --version failed ===" >&2
    echo "   Path: ${hadrian_path}" >&2
    echo "   Testing with ldd:" >&2
    ldd "${hadrian_path}" 2>&1 | head -20 >&2 || true
    return 1
  fi

  # Return FULL ABSOLUTE path (not just "hadrian") for command substitution
  echo "${hadrian_path}"
  return 0
}
