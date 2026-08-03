#!/usr/bin/env bash

export SWIFT="${CONDA_PREFIX}/bin/swiftc"
export SWIFTC="${SWIFT}"
export SWIFT_EXEC="${SWIFT}"
export CONDA_SWIFT_COMPILER=1

# The official Linux driver must be told where conda-forge's sysroot and GCC
# runtime objects live. The driver automatically consumes SWIFTFLAGS.
if [[ -n "${CONDA_BUILD_SYSROOT:-}" ]]; then
  swift_gcc_dir="$(find "${CONDA_PREFIX}/lib/gcc" -name crtbeginS.o -printf '%h\n' -quit 2>/dev/null)"
  if [[ -n "${swift_gcc_dir}" ]]; then
    export CONDA_SWIFTFLAGS_BACKUP="${SWIFTFLAGS:-}"
    export CONDA_SWIFTFLAGS_SET=1
    export SWIFTFLAGS="${SWIFTFLAGS:+${SWIFTFLAGS} }-sysroot ${CONDA_BUILD_SYSROOT} -Xclang-linker --gcc-install-dir=${swift_gcc_dir} -L ${CONDA_PREFIX}/lib -lstdc++"
  fi
  unset swift_gcc_dir
fi
