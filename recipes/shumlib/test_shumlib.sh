#!/usr/bin/env bash
set -euxo pipefail

# .mod ABI check: gfortran can only read module files written by its own
# generation, so compiling `use f_shum_string_conv_mod` against shumlib's installed
# module proves this environment's gfortran agrees with the one shumlib was built
# with. -fsyntax-only keeps it link-free -- the point is the .mod, not the link.
#
# FFLAGS/CPPFLAGS carry -I$PREFIX/include from the Fortran compiler activation;
# pass it explicitly too so the test does not depend on which one gfortran reads.
# These are flag STRINGS and must word-split.
# shellcheck disable=SC2086
${FC} -fsyntax-only ${FFLAGS} -I"$PREFIX/include" test_shumlib.f90
echo SHUMLIB_MODULES_OK

# libshum must resolve its own runtime dependencies (this is exactly the check
# that caught xios's missing libblitz.so). The shared library is .so on linux and
# .dylib on macOS; the ldd "not found" gate runs where ldd exists (linux) and is
# skipped on macOS (which has no ldd).
case "$(uname -s)" in
  Darwin) lib="$PREFIX/lib/libshum.dylib" ;;
  *)      lib="$PREFIX/lib/libshum.so" ;;
esac
test -f "$lib"
if command -v ldd >/dev/null 2>&1; then
  if ldd "$lib" | grep -i "not found"; then
    echo "ERROR: unresolved runtime dependencies in $lib"
    exit 1
  fi
fi
echo SHUMLIB_LIB_OK
