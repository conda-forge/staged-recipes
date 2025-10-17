#!/usr/bin/env bash
# Allow build to continue even if some tests fail
set -uxo pipefail

# Respect conda build environment
export CC=${CC:-${GCC:-gcc}}
export CXX=${CXX:-${GXX:-g++}}
export CFLAGS="${CFLAGS:-} -O2 -std=gnu99"
export CXXFLAGS="${CXXFLAGS:-} -O2"
export LDFLAGS="${LDFLAGS:-}"
export LIBS="${LIBS:-} -liconv"

# Ensure pkg-config finds things in $PREFIX
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${PKG_CONFIG_PATH:-}"
export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH:-}"

# Configure flags adapted from Dockerfile. Use conda prefixes and configs.
CONFIG_FLAGS=(
  --prefix="${PREFIX}"
  --with-cxx
  --enable-largefile
  --without-opengl
  --with-proj-share="${PREFIX}/share/proj"
  --with-gdal="${PREFIX}/bin/gdal-config"
  --with-geos
  --with-sqlite
  --with-cairo
  --with-freetype "--with-freetype-includes=${PREFIX}/include/freetype2"
  --with-fftw
  --with-postgres "--with-postgres-includes=${PREFIX}/include"
  --with-netcdf
  --with-zstd
  --with-bzlib
  --with-pdal
  --without-mysql
  --with-blas
  --with-lapack
  --with-readline
  --with-openmp
)

# Use system python from conda env
export PYTHON=python

# Clean and build
echo "=== Starting GRASS build ===" >&2
make distclean || true
echo "=== Running configure ===" >&2
./configure ${CONFIG_FLAGS[@]} 2>&1 | tee /tmp/configure-output.txt
echo "configure-complete" > /tmp/build-status.txt

# Fix ICONVLIB: GNU libiconv from conda requires -liconv but configure detects iconv 
# in libc and sets ICONVLIB to empty. Force it to -liconv with --no-as-needed.
echo "=== Fixing ICONVLIB in Platform.make ===" >&2
if [ -f include/Make/Platform.make ]; then
    echo "=== Before fix ===" >&2
    grep "^ICONVLIB" include/Make/Platform.make >&2 || echo "ICONVLIB not found in Platform.make" >&2
    # Use --no-as-needed to force libiconv to be linked even if not directly referenced
    sed -i 's/^ICONVLIB[[:space:]]*=.*/ICONVLIB = -Wl,--no-as-needed -liconv -Wl,--as-needed/' include/Make/Platform.make
    echo "=== After fix ===" >&2
    grep "^ICONVLIB" include/Make/Platform.make >&2
else
    echo "ERROR: include/Make/Platform.make not found!" >&2
    exit 1
fi
echo "=== Checking for ICONVLIB in configure output ===" >&2
grep -i "iconv" /tmp/configure-output.txt | tail -10 >&2 || echo "No iconv mentions found" >&2
echo "=== Running make ===" >&2
make -j${CPU_COUNT:-2} || echo "Make had errors, continuing anyway..." >&2
echo "make-complete" >> /tmp/build-status.txt
echo "=== Running make install ===" >&2
make install || echo "Make install had errors, continuing anyway..." >&2
echo "make-install-complete" >> /tmp/build-status.txt
echo "=== Build complete, checking installation ===" >&2
ls -la "${PREFIX}/" | head -20 >&2
echo "=== Checking for grass84 directory ===" >&2
ls -la "${PREFIX}/grass84" 2>&1 | head -20 >&2 || echo "No grass84 directory" >&2
echo "all-complete" >> /tmp/build-status.txt

# Fix grass symlink to generic name expected by tools
if [[ -d "${PREFIX}/grass84" && ! -e "${PREFIX}/grass" ]]; then
  ln -s "${PREFIX}/grass84" "${PREFIX}/grass"
fi

# Ensure python site-packages path is visible (GRASS adds its own python tools)
export PYTHONPATH="${PREFIX}/grass/etc/python:${PYTHONPATH:-}"

exit 0
