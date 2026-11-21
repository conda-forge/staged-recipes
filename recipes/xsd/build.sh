#!/bin/bash
set -euxo pipefail

# The bundled source ships files named "version" in the includes. These shadow 
# the standard C++ <version> header, so rename them out of the way.
# This follows the practice in the Homebrew XSD formula
# (https://github.com/Homebrew/homebrew-core/tree/6afc8766).
mv xsd/version xsd/version.txt
mv libxsd-frontend/version libxsd-frontend/version.txt
mv libcutl/version libcutl/version.txt

# The build-0.3 make system marks Xerces-C++ as "installed" and links it via a
# bare "-lxerces-c". Add the full link flag with the $PREFIX library path.
# Try to get full path from pkg-config
xerces_libs="$(pkg-config --libs xerces-c 2>/dev/null || true)"
# Fall back to a manual path if pkg-config fails
if [ -z "${xerces_libs}" ]; then
  xerces_libs="-L${PREFIX}/lib -lxerces-c"
fi
export LDFLAGS="${LDFLAGS} ${xerces_libs}"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

# Closing stdin (< /dev/null, below) makes the build-0.3 configure dialog take
# its defaults; passing CC/CXX/AR/RANLIB avoids its compiler-selection prompt.
# .LIBPATTERNS lets make resolve the bare "-lxerces-c" prerequisite: lib%.dylib
# covers macOS while lib%.so/.a cover Linux, and VPATH points the library
# search at $PREFIX/lib.
make_args=(
  CC="${CC}"
  CXX="${CXX}"
  AR="${AR}"
  RANLIB="${RANLIB}"
  CPPFLAGS="${CPPFLAGS}"
  CXXFLAGS="${CXXFLAGS} -std=c++11"
  LDFLAGS="${LDFLAGS}"
  ".LIBPATTERNS=lib%.dylib lib%.so lib%.a"
  VPATH="${PREFIX}/lib"
)

make -j"${CPU_COUNT}" "${make_args[@]}" < /dev/null
make install_prefix="${PREFIX}" install "${make_args[@]}" < /dev/null
