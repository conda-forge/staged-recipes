#!/usr/bin/env bash
set -e

# Installed as PREFIX/bin/<tool> and, on Linux, as the toolchain's own
# libexec/swift/usr/bin/swiftc so that SwiftPM also goes through it.
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
case "${script_dir}" in
  */libexec/swift/usr/bin) prefix="${script_dir%/libexec/swift/usr/bin}" ;;
  *) prefix="${script_dir%/bin}" ;;
esac
tool="$(basename -- "$0")"
toolchain_bin="${prefix}/libexec/swift/usr/bin"
export SWIFT_EXEC="${SWIFT_EXEC:-${toolchain_bin}/swiftc}"

real_tool="${toolchain_bin}/${tool}"
if [[ "${tool}" == swiftc && -e "${prefix}/libexec/swift/driver/swiftc" ]]; then
  # On Linux the toolchain's swiftc is this wrapper. The Swift driver selects
  # its mode from the invoked basename, so the private symlink keeps "swiftc".
  real_tool="${prefix}/libexec/swift/driver/swiftc"
fi

# Classify the invocation:
#   driver   - swiftc, or swift with a source file or option (interpreter)
#   frontend - swiftc -frontend ...; -frontend must stay the first argument
#   swiftpm  - swift build/run/test or the swift-build/run/test tools
#   other    - everything else, passed through unchanged
mode=other
case "${tool}" in
  swiftc) mode=driver ;;
  swift-build | swift-run | swift-test) mode=swiftpm ;;
  swift)
    case "${1:-}" in
      build | run | test) mode=swiftpm ;;
      -* | *.swift) mode=driver ;;
    esac
    ;;
esac
if [[ "${mode}" == driver && "${1:-}" == -frontend ]]; then
  mode=frontend
fi
has_target=0
for arg in "$@"; do
  case "${arg}" in
    # SwiftPM wraps already-built ASTs with this; it rejects other options.
    -modulewrap) mode=other ;;
    -target | -target=* | --target | --target=*) has_target=1 ;;
  esac
done

if [[ "$(uname)" == Linux && "${mode}" != other ]]; then
  # The upstream driver does not know where conda-forge installs its sysroot
  # and GCC runtime.
  swift_sysroot=""
  for candidate in "${prefix}"/*/sysroot; do
    if [[ -d "${candidate}" ]]; then
      swift_sysroot="${candidate}"
      break
    fi
  done
  swift_gcc_dir=""
  for candidate in "${prefix}"/lib/gcc/*/*; do
    if [[ -f "${candidate}/crtbeginS.o" ]]; then
      swift_gcc_dir="${candidate}"
    fi
  done
  # Link against the target environment (PREFIX during conda builds) and let
  # the linker resolve the Swift runtime's own dependencies there.
  target_prefix="${PREFIX:-${prefix}}"
  linker_args=(
    -L "${target_prefix}/lib"
    -rpath-link "${target_prefix}/lib"
    -rpath-link "${prefix}/lib"
    -rpath "${target_prefix}/libexec/swift/usr/lib/swift/linux"
  )

  case "${mode}" in
    frontend)
      if [[ -n "${swift_sysroot}" ]]; then
        exec "${real_tool}" "$@" -sysroot "${swift_sysroot}"
      fi
      ;;
    driver)
      extra_args=()
      if [[ -n "${swift_sysroot}" ]]; then
        extra_args+=(-sysroot "${swift_sysroot}")
      fi
      if [[ "${tool}" == swiftc ]]; then
        if [[ -n "${swift_gcc_dir}" ]]; then
          extra_args+=(-Xclang-linker "--gcc-install-dir=${swift_gcc_dir}")
        fi
        for arg in "${linker_args[@]}"; do
          extra_args+=(-Xlinker "${arg}")
        done
      fi
      exec "${real_tool}" "${extra_args[@]}" "$@"
      ;;
    swiftpm)
      # SwiftPM runs the Swift driver in-process, bypassing the swiftc wrapper,
      # so hand it the same settings. They go right after the subcommand,
      # before any executable name or arguments for "swift run".
      spm_args=()
      if [[ -n "${swift_sysroot}" ]]; then
        spm_args+=(-Xswiftc -sysroot -Xswiftc "${swift_sysroot}" -Xcc "--sysroot=${swift_sysroot}")
      fi
      if [[ -n "${swift_gcc_dir}" ]]; then
        spm_args+=(
          -Xcc "--gcc-install-dir=${swift_gcc_dir}"
          -Xswiftc -Xclang-linker -Xswiftc "--gcc-install-dir=${swift_gcc_dir}"
        )
      fi
      for arg in "${linker_args[@]}"; do
        spm_args+=(-Xlinker "${arg}")
      done
      if [[ "${tool}" == swift ]]; then
        subcommand="$1"
        shift
        exec "${real_tool}" "${subcommand}" "${spm_args[@]}" "$@"
      fi
      exec "${real_tool}" "${spm_args[@]}" "$@"
      ;;
  esac
elif [[ "$(uname)" == Darwin && "${mode}" == driver && "${has_target}" == 0 && -n "${MACOSX_DEPLOYMENT_TARGET:-}" ]]; then
  # swiftc otherwise targets the build machine's macOS version, not the
  # environment's deployment target.
  arch="${HOST:-$(uname -m)}"
  exec "${real_tool}" -target "${arch%%-*}-apple-macosx${MACOSX_DEPLOYMENT_TARGET}" "$@"
fi

exec "${real_tool}" "$@"
