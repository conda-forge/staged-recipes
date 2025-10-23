
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
