
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

  # Hadrian dependency list (same across all platforms)
  local hadrian_deps=(
    clock
    file-io
    heaps
    js-dgtable
    js-flot
    js-jquery
    directory
    os-string
    splitmix
    utf8-string
    hashable
    process
    primitive
    random
    QuickCheck
    unordered-containers
    extra
    Cabal-syntax
    filepattern
    Cabal
    shake
    hadrian
  )

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

  echo "   DEBUG: Raw hadrian_path from find: ${hadrian_path}" >&2

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
  echo "   DEBUG: Converting to absolute path..." >&2
  echo "   DEBUG: dirname: $(dirname "${hadrian_path}")" >&2
  echo "   DEBUG: basename: $(basename "${hadrian_path}")" >&2

  hadrian_path="$(cd "$(dirname "${hadrian_path}")" 2>/dev/null && pwd)/$(basename "${hadrian_path}")" || {
    echo "   DEBUG: Failed to convert to absolute path, using as-is" >&2
  }

  echo "   DEBUG: Final hadrian_path: ${hadrian_path}" >&2

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
