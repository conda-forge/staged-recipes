#!/usr/bin/env bash

export CFLAGS="$CFLAGS -std=c11 -D_GNU_SOURCE $(pkg-config --cflags libfyaml)"
export LDFLAGS="-Wl,-rpath,$PREFIX/lib $(pkg-config --libs libfyaml)"

# Patches were generated using the following method:
# 1. git clone https://github.com/asdf-format/libasdf
# 2. cd libasdf
# 3. git checkout -b [NAME] [TAG]
# 4. Make changes
# 5. git add [FILE]
# 6. git commit -m 'Useful message'
# 7. Repeat steps 4-5 until finished
# 8. git format-patch -o /path/to/recipe/patches [TAG]
#
# To add new patches
# 1. git checkout -b [NAME] [TAG]
# 2. git am /path/to/recipe/patches/*.patch
# 3. Repeat steps 4-7 above
# 4. Do step 8 above
#
# Include the patch file name(s) in the array below
# patches=(
#   FILE1.patch
#   FILE2.patch
#   ...
# )
patches=(
    0001-build-attempt-to-fix-autotools-build-in-conda-enviro.patch
    0002-Fix-build-system.patch
)

# Apply patches
for p in "${patches[@]}"; do
    patch -p1 < "$RECIPE_DIR/patches/$p"
done

# Bootstrap for local autotools
autoreconf -i

# Configure
./configure --prefix="$PREFIX" \
    --with-gwcs \
    --without-libstatgrab
    CFLAGS="${CFLAGS}" \
    CPPFLAGS="${CPPFLAGS}" \
    LDFLAGS="${LDFLAGS}"

# Build
make V=1

# Test
make check

# Install
make install

datadir="$PREFIX"/share/libasdf
mkdir -p "$datadir"
install -m 644 CHANGES.rst "$datadir"
install -m 644 LICENSE "$datadir"/LICENSE.txt
install -m 644 third_party/STC/LICENSE "$datadir"/LICENSE_STC.txt

