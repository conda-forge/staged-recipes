#!/usr/bin/env bash

export SWIFT="${CONDA_PREFIX}/bin/swiftc"
export SWIFTC="${SWIFT}"
export SWIFT_EXEC="${SWIFT}"
export CONDA_SWIFT_COMPILER=1

# The official Linux driver must be told where conda-forge's sysroot and GCC
# runtime objects live. The driver automatically consumes SWIFTFLAGS.
swift_sysroot="${CONDA_BUILD_SYSROOT:-}"
if [[ -z "${swift_sysroot}" ]]; then
  for swift_dir in "${CONDA_PREFIX}"/*/sysroot; do
    if [[ -d "${swift_dir}" ]]; then
      swift_sysroot="${swift_dir}"
      break
    fi
  done
fi
swift_gcc_dir=""
for swift_dir in "${CONDA_PREFIX}"/lib/gcc/*/*; do
  if [[ -f "${swift_dir}/crtbeginS.o" ]]; then
    swift_gcc_dir="${swift_dir}"
    break
  fi
done
if [[ -n "${swift_sysroot}" && -n "${swift_gcc_dir}" ]]; then
  export CONDA_SWIFTFLAGS_BACKUP="${SWIFTFLAGS:-}"
  export CONDA_SWIFTFLAGS_SET=1
  export SWIFTFLAGS="${SWIFTFLAGS:+${SWIFTFLAGS} }-sysroot ${swift_sysroot} -Xclang-linker --gcc-install-dir=${swift_gcc_dir} -L ${CONDA_PREFIX}/lib -lstdc++"
fi
unset swift_sysroot swift_gcc_dir swift_dir

# A sourced activation hook must always return success.
true
