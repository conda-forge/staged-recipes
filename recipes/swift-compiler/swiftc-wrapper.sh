#!/usr/bin/env bash
set -e

bin_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
prefix="${bin_dir%/bin}"
real_driver="${prefix}/libexec/swift/bin/swiftc"

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
    break
  fi
done

extra_args=()
add_toolchain_args=1
for arg in "$@"; do
  # SwiftPM uses this frontend-style mode only to wrap an already-built AST;
  # the normal driver/linker options are invalid for that invocation.
  if [[ "${arg}" == -modulewrap ]]; then
    add_toolchain_args=0
    break
  fi
done
if [[ "${add_toolchain_args}" == 1 && -n "${swift_sysroot}" && -n "${swift_gcc_dir}" ]]; then
  extra_args+=(
    -sysroot "${swift_sysroot}"
    -Xclang-linker "--gcc-install-dir=${swift_gcc_dir}"
    -L "${prefix}/lib"
    -lstdc++
  )
fi

# The Swift driver selects its mode from the invoked path's basename, so the
# private symlink deliberately retains the name "swiftc".
exec "${real_driver}" "${extra_args[@]}" "$@"
