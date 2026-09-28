#!/bin/bash
set -euxo pipefail

# Build the native non-MPI runtime from source. CFITSIO is provided by the
# conda host environment and is not vendored into the conda package.
export XSTAR_TOOLS_NATIVE=required
export XSTAR_TOOLS_NATIVE_JOBS="${CPU_COUNT:-2}"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${PKG_CONFIG_PATH:-}"

# GNU ld must be able to resolve CFITSIO when linking the public xstar-cpp
# frontend against libxstar_production_zone.so.  The 0.6.89.5 Makefile links
# CFITSIO into that shared library, but the final frontend link does not repeat
# the CFITSIO search path.  conda-forge uses a sysrooted GNU linker, for which
# an explicit rpath-link is the correct link-time search path.  This is Linux
# only; Apple ld does not support -rpath-link.  Once an upstream release carries
# the equivalent Makefile fix, this extra search path remains harmless.
if [[ "$(uname -s)" == "Linux" ]]; then
    export CXXFLAGS="${CXXFLAGS:-} -Wl,-rpath-link,${PREFIX}/lib"
fi

# 0.6.90+ provides a dedicated conda profile. The first conda-forge submission
# packages the already-published 0.6.89.5 release, whose accepted native
# profiles are pypi-linux / pypi-macos. Keep this compatibility probe so the
# conda-forge version bot can update future PyPI releases without requiring a
# simultaneous build-script edit.
if "${PYTHON}" - <<'PY'
import build_support

try:
    ok = build_support._native_make_target("conda") == "conda"
except Exception:
    ok = False
raise SystemExit(0 if ok else 1)
PY
then
    export XSTAR_TOOLS_NATIVE_PROFILE=conda
else
    case "$(uname -s)" in
        Linux)
            export XSTAR_TOOLS_NATIVE_PROFILE=pypi-linux
            ;;
        Darwin)
            export XSTAR_TOOLS_NATIVE_PROFILE=pypi-macos
            ;;
        *)
            echo "unsupported conda native build platform: $(uname -s)" >&2
            exit 2
            ;;
    esac
fi

"${PYTHON}" -m pip install . --no-deps --no-build-isolation -vv
