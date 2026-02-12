#!/usr/bin/env bash
# Unified selective tool building for QEMU
# Eliminates 5x repeated build-and-install patterns

# Map tool name to ninja build target (some tools are in subdirectories)
get_ninja_target() {
  local tool=$1
  case "${tool}" in
    qemu-ga|qemu-ga.exe)
      echo "qga/qemu-ga${tool##qemu-ga}"
      ;;
    qemu-storage-daemon|qemu-storage-daemon.exe)
      echo "storage-daemon/qemu-storage-daemon${tool##qemu-storage-daemon}"
      ;;
    elf2dmp|elf2dmp.exe)
      echo "contrib/elf2dmp/elf2dmp${tool##elf2dmp}"
      ;;
    *)
      echo "${tool}"
      ;;
  esac
}

# Install specific QEMU tools from build directory to install directory
# Usage: install_qemu_tools <build_dir> <install_dir> <tool1> [tool2] ...
install_qemu_tools() {
  local build_dir=$1
  local install_dir=$2
  shift 2
  local tools=("$@")

  mkdir -p "${install_dir}/bin"
  mkdir -p "${install_dir}/libexec"

  for tool in "${tools[@]}"; do
    local src=""
    local dst=""

    case "${tool}" in
      # Direct binaries (build artifact name = install name)
      qemu-img*|qemu-io*|qemu-nbd*|qemu-edid*|qemu-keymap*|qemu-pr-helper*|qemu-vmsr-helper*)
        src="${build_dir}/${tool}"
        dst="${install_dir}/bin/${tool}"
        ;;
      # Binaries in subdirectories
      qemu-ga*)
        src="${build_dir}/qga/qemu-ga"
        dst="${install_dir}/bin/${tool}"
        ;;
      qemu-storage-daemon*)
        src="${build_dir}/storage-daemon/qemu-storage-daemon"
        dst="${install_dir}/bin/${tool}"
        ;;
      elf2dmp*)
        src="${build_dir}/contrib/elf2dmp/elf2dmp"
        dst="${install_dir}/bin/${tool}"
        ;;
      # Special install location
      qemu-bridge-helper*)
        src="${build_dir}/qemu-bridge-helper"
        dst="${install_dir}/libexec/${tool}"
        ;;
      *)
        echo "WARNING: Unknown tool '${tool}', skipping"
        continue
        ;;
    esac

    if [[ -f "${src}" ]]; then
      echo "Installing: ${tool} -> ${dst}"
      install -m 755 "${src}" "${dst}"
    else
      echo "ERROR: Built artifact not found: ${src}"
      return 1
    fi
  done
}

# Build and install tools from a single environment variable
# Usage: build_and_install_tools <build_dir> <install_dir> <tools_env_value> [add_exe_suffix]
# Args:
#   build_dir: Build directory containing compiled tools
#   install_dir: Installation prefix
#   tools_env_value: Space-separated list of tool names
#   add_exe_suffix: "true" to add .exe suffix (Windows builds)
build_and_install_tools() {
  local build_dir=$1
  local install_dir=$2
  local tools_env_value=$3
  local add_exe_suffix=${4:-false}

  [[ -z "${tools_env_value}" ]] && return 0

  read -ra TOOLS_ARRAY <<< "${tools_env_value}"

  # Add .exe suffix for Windows builds
  if [[ "${add_exe_suffix}" == "true" ]]; then
    TOOLS_ARRAY=("${TOOLS_ARRAY[@]/%/.exe}")
  fi

  # Map to ninja targets (some tools are in subdirectories)
  local NINJA_TARGETS=()
  for tool in "${TOOLS_ARRAY[@]}"; do
    NINJA_TARGETS+=("$(get_ninja_target "${tool}")")
  done

  echo "Building specific tools: ${NINJA_TARGETS[*]}"

  # Build with platform-appropriate ninja invocation
  if [[ "${add_exe_suffix}" == "true" ]]; then
    MSYS2_ARG_CONV_EXCL="*" ninja -j"${CPU_COUNT}" "${NINJA_TARGETS[@]}" || { echo "Build failed"; return 1; }
  else
    ninja -j"${CPU_COUNT}" "${NINJA_TARGETS[@]}"
  fi

  # Install the tools
  install_qemu_tools "${build_dir}" "${install_dir}" "${TOOLS_ARRAY[@]}"
}

# Build all tool sets based on platform
# Usage: build_selective_tools <build_dir> <install_dir> <is_windows>
build_selective_tools() {
  local build_dir=$1
  local install_dir=$2
  local is_windows=${3:-false}

  # Common tools (all platforms)
  build_and_install_tools "${build_dir}" "${install_dir}" "${CONDA_QEMU_TOOLS:-}" "${is_windows}"

  # Non-macOS tools (Linux + Windows)
  if [[ "${target_platform}" != osx-* ]] && [[ -n "${CONDA_QEMU_NOSX_TOOLS:-}" ]]; then
    build_and_install_tools "${build_dir}" "${install_dir}" "${CONDA_QEMU_NOSX_TOOLS}" "${is_windows}"
  fi

  # Linux-only tools
  if [[ "${target_platform}" == linux-* ]] && [[ -n "${CONDA_QEMU_LINUX_TOOLS:-}" ]]; then
    build_and_install_tools "${build_dir}" "${install_dir}" "${CONDA_QEMU_LINUX_TOOLS}" "false"
  fi
}
