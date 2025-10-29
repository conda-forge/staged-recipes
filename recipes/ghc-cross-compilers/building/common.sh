
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

  echo "=== Building Hadrian with dependencies ==="
  echo "  GHC: ${ghc_path}"
  echo "  AR: ${ar_stage0}"
  echo "  CC: ${cc_stage0}"
  echo "  LD: ${ld_stage0}"

  pushd "${SRC_DIR}/hadrian" || return 1

  # CRITICAL: Override CFLAGS/LDFLAGS if provided
  # This prevents target architecture flags from contaminating Hadrian build
  if [[ -n "$extra_cflags" ]]; then
    echo "  Overriding CFLAGS for build machine:"
    echo "    ${extra_cflags}"
    export CFLAGS="$extra_cflags"
  fi

  if [[ -n "$extra_ldflags" ]]; then
    echo "  Overriding LDFLAGS for build machine:"
    echo "    ${extra_ldflags}"
    export LDFLAGS="$extra_ldflags"
  fi

  export CABFLAGS=(--enable-shared --enable-executable-dynamic -j)

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

  "${CABAL}" v2-build \
    --with-ar="${ar_stage0}" \
    --with-gcc="${cc_stage0}" \
    --with-ghc="${ghc_path}" \
    --with-ld="${ld_stage0}" \
    -j \
    "${hadrian_deps[@]}" \
    2>&1 | tee "${SRC_DIR}/cabal-verbose.log"

  local exit_code=${PIPESTATUS[0]}

  popd || return 1

  if [[ $exit_code -ne 0 ]]; then
    echo "=== Cabal build FAILED with exit code ${exit_code} ==="
    echo "See ${SRC_DIR}/cabal-verbose.log for details"
    return 1
  fi

  # Find hadrian binary location
  local hadrian_path
  hadrian_path=$(find "${SRC_DIR}/hadrian" -type f -name hadrian -executable | head -1)

  if [[ -z "$hadrian_path" ]]; then
    echo "=== ERROR: Could not find hadrian binary ===" >&2
    return 1
  fi

  # Export for convenience
  export HADRIAN_BIN="${hadrian_path}"

  echo "=== Hadrian build completed successfully ===" >&2
  echo "  Hadrian binary: ${hadrian_path}" >&2

  # Return path for command substitution: HADRIAN_BUILD=$(build_hadrian_cross ...)
  echo "${hadrian_path}"
  return 0
}
