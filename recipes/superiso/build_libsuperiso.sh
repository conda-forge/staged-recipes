#!/usr/bin/env bash

set -x
set -e
set -u
set -o pipefail

# SuperIso ships a plain Makefile that hardcodes `gcc`/`-O3` and, by default, builds only
# a STATIC `src/libsuperiso.a` (the `all` target); there is no shared-library build and no
# `install` target. Inject the conda toolchain through the otherwise-empty `CFLAGS_MP`
# hook: every compile/link rule appends `$(CFLAGS_MP)`, and the top Makefile propagates it
# to `src/` via the generated `src/FlagsForMake`. Going through CFLAGS_MP (instead of
# overriding CFLAGS) leaves upstream's fragile `-DVERSION=\"v5.0\"` defines untouched.
# conda's $CFLAGS already contains -fPIC, so the archived objects are position-independent
# and can be relinked into a shared library.
make CC="${CC}" AR="${AR}" CFLAGS_MP="${CFLAGS}"

# Relink the (PIC) objects from the static archive into a shared object
install -d "${PREFIX}/lib" "${PREFIX}/include/superiso"
pushd src
ar x libsuperiso.a
if [[ "$(uname)" == "Darwin" ]]; then
  ${CC} -dynamiclib ${LDFLAGS} -install_name "@rpath/libsuperiso.dylib" \
    -o "${PREFIX}/lib/libsuperiso.dylib" ./*.o -lm
else
  ${CC} -shared ${LDFLAGS} -Wl,-soname,libsuperiso.so \
    -o "${PREFIX}/lib/libsuperiso.so" ./*.o -lm
fi
popd

install -m 0644 src/include.h "${PREFIX}/include/superiso/"
