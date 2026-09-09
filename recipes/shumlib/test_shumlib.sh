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

# libshum must resolve its own runtime dependencies. SHLIB_EXT is supplied by
# the build tool and is .so on linux and .dylib on macOS.
lib="$PREFIX/lib/libshum${SHLIB_EXT}"
test -f "$lib"

# Each platform has its own tool for listing what a shared library needs, so
# branch on which one to ask; the listing is printed either way so the CI log
# records what libshum ended up linked against.
case "$(uname -s)" in
  Darwin)
    # otool -L reports the install names libshum records, without resolving
    # them. conda rewrites the ones it owns to @rpath/<name> and points the
    # rpath at $PREFIX/lib, so those are satisfied exactly when the named file
    # is there. macOS's own libraries under /usr/lib and /System live in the
    # dyld shared cache rather than on disk, so they are not checked.
    linkage=$(otool -L "$lib")
    printf '%s\n' "$linkage"
    for dep in $(printf '%s\n' "$linkage" | tail -n +2 | awk '{print $1}'); do
      case "$dep" in
        /usr/lib/*|/System/*) continue ;;
        @rpath/*) dep="$PREFIX/lib/${dep#@rpath/}" ;;
      esac
      if [ ! -e "$dep" ]; then
        echo "ERROR: unresolved runtime dependency $dep in $lib"
        exit 1
      fi
    done
    ;;
  *)
    # ldd resolves the dependencies itself and writes "not found" against any
    # it cannot satisfy.
    linkage=$(ldd "$lib")
    printf '%s\n' "$linkage"
    if printf '%s\n' "$linkage" | grep -i "not found"; then
      echo "ERROR: unresolved runtime dependencies in $lib"
      exit 1
    fi
    ;;
esac
echo SHUMLIB_LIB_OK

# The version shumlib reports comes from its CMakeLists.txt, which upstream
# forgot to bump for this release and the recipe patches; check the generated
# pkg-config file agrees with the package so the patch cannot silently stop
# applying on a future version bump.
pc="$PREFIX/lib/pkgconfig/shumlib.pc"
cat "$pc"
grep -qx "Version: ${PKG_VERSION}" "$pc"
echo SHUMLIB_VERSION_OK
