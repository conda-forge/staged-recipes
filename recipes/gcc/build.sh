#!/bin/bash

# Install gcc to its very own prefix.
# GCC must not be installed to the same prefix as the environment,
# because $GCC_PREFIX/include is automatically considered to be a
# "system" header path.
# That could cause -I$PREFIX/include to be essentially ignored in users' recipes
# (It would still be on the search path, but it would be in the wrong position in the search order.)
GCC_PREFIX="$PREFIX/gcc"
mkdir "$GCC_PREFIX"

ln -s "$PREFIX/lib" "$PREFIX/lib64"

if [ "$(uname)" == "Darwin" ]; then
    # On Mac, we expect that the user has installed the xcode command-line utilities (via the 'xcode-select' command).
    # The system's libstdc++.6.dylib will be located in /usr/lib, and we need to help the gcc build find it.
    export LDFLAGS="-Wl,-headerpad_max_install_names -Wl,-L${PREFIX}/lib -Wl,-L/usr/lib"
    export DYLD_FALLBACK_LIBRARY_PATH="$PREFIX/lib:/usr/lib"

    ./configure \
        --prefix="$GCC_PREFIX" \
        --with-gxx-include-dir="$GCC_PREFIX/include/c++" \
        --bindir="$PREFIX/bin" \
        --datarootdir="$PREFIX/share" \
        --libdir="$PREFIX/lib" \
        --with-gmp="$PREFIX" \
        --with-mpfr="$PREFIX" \
        --with-mpc="$PREFIX" \
        --with-isl="$PREFIX" \
        --with-cloog="$PREFIX" \
        --with-boot-ldflags="$LDFLAGS" \
        --with-stage1-ldflags="$LDFLAGS" \
        --enable-checking=release \
        --with-tune=generic \
        --disable-multilib
else
    # For reference during post-link.sh, record some
    # details about the OS this binary was produced with.
    mkdir -p "${PREFIX}/share"
    cat /etc/*-release > "${PREFIX}/share/conda-gcc-build-machine-os-details"
    ./configure \
        --prefix="$GCC_PREFIX" \
        --with-gxx-include-dir="$GCC_PREFIX/include/c++" \
        --bindir="$PREFIX/bin" \
        --datarootdir="$PREFIX/share" \
        --libdir="$PREFIX"/lib \
        --with-gmp="$PREFIX" \
        --with-mpfr="$PREFIX" \
        --with-mpc="$PREFIX" \
        --with-isl="$PREFIX" \
        --with-cloog="$PREFIX" \
        --enable-checking=release \
        --with-tune=generic \
        --disable-multilib
fi
make -j"$CPU_COUNT"
make install-strip
rm "$PREFIX/lib64"

# Link cc to gcc if cc doesn't exist
[ -e "$PREFIX/bin/cc" ] || ln -s "gcc" "$PREFIX/bin/cc"
