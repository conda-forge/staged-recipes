
#!/usr/bin/env bash
# Allow build to continue even if some tests fail
set -uxo pipefail

# Extract version components from PKG_VERSION (set by conda-build from meta.yaml)
# PKG_VERSION format: MAJOR.MINOR.PATCH (e.g., "8.4.1")
IFS='.' read -r GRASS_MAJOR GRASS_MINOR GRASS_PATCH <<< "${PKG_VERSION}"
GRASS_VERSION_DIR="grass${GRASS_MAJOR}${GRASS_MINOR}"
echo "=== GRASS Version: ${PKG_VERSION} (using directory: ${GRASS_VERSION_DIR}) ===" >&2
echo "=== Version components: MAJOR=${GRASS_MAJOR}, MINOR=${GRASS_MINOR}, PATCH=${GRASS_PATCH} ===" >&2

# Respect conda build environment
export CC=${CC:-${GCC:-gcc}}
export CXX=${CXX:-${GXX:-g++}}
export CFLAGS="${CFLAGS:-} -O2 -std=gnu99"
export CXXFLAGS="${CXXFLAGS:-} -O2"
export LDFLAGS="${LDFLAGS:-}"

# Platform-specific settings
if [[ "$OSTYPE" == "darwin"* ]]; then
    export LIBS="${LIBS:-} -liconv"
    # macOS linker flags
    export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
else
    export LIBS="${LIBS:-} -liconv"
fi

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

# Add X11 only on Linux
if [[ "$OSTYPE" != "darwin"* ]]; then
    CONFIG_FLAGS+=(--with-x)
else
    CONFIG_FLAGS+=(--without-x)
fi

# Use system python from conda env
export PYTHON=python

# Clean and build
echo "=== Starting GRASS build ===" >&2
make distclean || true
echo "=== Running configure ===" >&2
./configure ${CONFIG_FLAGS[@]} 2>&1 | tee /tmp/configure-output.txt
echo "configure-complete" > /tmp/build-status.txt

## IMPORTANT: Fix ICONVLIB immediately after configure and BEFORE make
# GNU libiconv from conda requires -liconv but configure often detects iconv in
# glibc and leaves ICONVLIB empty. Force linking against libiconv so libgrass_gis
# gets a DT_NEEDED entry for libiconv and avoids runtime "undefined symbol: libiconv".
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "=== Fixing ICONVLIB in Platform.make (Linux) BEFORE make ===" >&2
    if [ -f include/Make/Platform.make ]; then
        echo "=== Before fix ===" >&2
        grep "^ICONVLIB" include/Make/Platform.make >&2 || echo "ICONVLIB not found in Platform.make" >&2
        # Use --no-as-needed to force libiconv to be linked even if lazily referenced
        # Cross-platform sed: create backup then remove it
        sed -i.bak 's/^ICONVLIB[[:space:]]*=.*/ICONVLIB = -Wl,--no-as-needed -liconv -Wl,--as-needed/' include/Make/Platform.make && rm include/Make/Platform.make.bak
        echo "=== After fix ===" >&2
        grep "^ICONVLIB" include/Make/Platform.make >&2
    fi
else
    echo "=== Fixing ICONVLIB in Platform.make (macOS) BEFORE make ===" >&2
    if [ -f include/Make/Platform.make ]; then
        echo "=== Before fix ===" >&2
        grep "^ICONVLIB" include/Make/Platform.make >&2 || echo "ICONVLIB not found in Platform.make" >&2
        # Force libiconv to be linked on macOS
        # Cross-platform sed: create backup then remove it
        sed -i.bak 's/^ICONVLIB[[:space:]]*=.*/ICONVLIB = -liconv/' include/Make/Platform.make && rm include/Make/Platform.make.bak
        echo "=== After fix ===" >&2
        grep "^ICONVLIB" include/Make/Platform.make >&2
    fi
fi

echo "=== Running make ===" >&2
make -j${CPU_COUNT:-2}
echo "make-complete" >> /tmp/build-status.txt

echo "=== Running make install ===" >&2
make install
echo "make-install-complete" >> /tmp/build-status.txt

# GRASS_VERSION_DIR already defined at the top from PKG_VERSION
# Fix grass symlink to generic name expected by tools
if [[ -d "${PREFIX}/${GRASS_VERSION_DIR}" && ! -e "${PREFIX}/grass" ]]; then
  ln -s "${PREFIX}/${GRASS_VERSION_DIR}" "${PREFIX}/grass"
fi

# Symlink all GRASS binaries to main bin directory for test discovery
echo "=== Creating symlinks for GRASS binaries ===" >&2
if [ -d "${PREFIX}/${GRASS_VERSION_DIR}/bin" ]; then
    for cmd in "${PREFIX}/${GRASS_VERSION_DIR}/bin"/*; do
        if [ -f "$cmd" ] && [ -x "$cmd" ]; then
            cmdname=$(basename "$cmd")
            # Don't overwrite existing binaries in $PREFIX/bin
            if [ ! -e "${PREFIX}/bin/${cmdname}" ]; then
                ln -sf "$cmd" "${PREFIX}/bin/${cmdname}"
            fi
        fi
    done
    echo "Created symlinks for GRASS binaries" >&2
fi

# Install conda activation scripts to add GRASS bin to PATH
echo "=== Installing conda activation scripts ===" >&2
mkdir -p "${PREFIX}/etc/conda/activate.d"
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cp "${RECIPE_DIR}/etc/conda/activate.d/grass-activate.sh" "${PREFIX}/etc/conda/activate.d/"
cp "${RECIPE_DIR}/etc/conda/deactivate.d/grass-deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/"
chmod +x "${PREFIX}/etc/conda/activate.d/grass-activate.sh"
chmod +x "${PREFIX}/etc/conda/deactivate.d/grass-deactivate.sh"
echo "Installed activation scripts" >&2

# Ensure python site-packages path is visible (GRASS adds its own python tools)
export PYTHONPATH="${PREFIX}/grass/etc/python:${PYTHONPATH:-}"

exit 0