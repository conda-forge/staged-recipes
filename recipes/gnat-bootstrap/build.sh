#!/bin/bash
set -exuo pipefail

# ---------------------------------------------------------------------------
# Helpers: rattler-build flattens single-root archives inside
# target_directory, but be robust against both layouts.
# ---------------------------------------------------------------------------
locate_root() {
  # locate_root <dir> <marker-relpath> -> echoes the directory containing marker
  local dir="$1" marker="$2"
  if [[ -e "${dir}/${marker}" ]]; then
    echo "${dir}"
  else
    dirname "$(find "${dir}" -maxdepth 2 -path "*/${marker}" | head -n1)"
  fi
}

GCC_SRC=$(locate_root "${SRC_DIR}/gcc" "gcc/ada/gnat1drv.adb")
SEED_ROOT=$(locate_root "${SRC_DIR}/gnat-seed" "bin/gnatmake")

# Like ghc-bootstrap and go1.4-bootstrap, install into a prefix subdirectory
# so the unprefixed toolchain names (gcc, as, ld, ...) can never collide with
# real compiler/binutils packages sharing an environment. Consumers discover
# it via the GNAT_BOOTSTRAP_HOME environment variable set on activation.
GNAT_PREFIX="${PREFIX}/gnat-bootstrap"

# ---------------------------------------------------------------------------
# Stage-0: the pinned GNAT-FSF-builds seed provides gcc/g++/gnat*.
# GCC's Ada sources must be compiled by an Ada-capable gcc driver, so the
# seed toolchain is used for the entire build (no conda compilers).
# ---------------------------------------------------------------------------
export PATH="${SEED_ROOT}/bin:${PATH}"
export CC=gcc
export CXX=g++
command -v gnatmake
gnatmake --version
gcc --version

# In-tree, statically linked prerequisites (same mechanism as gcc's
# contrib/download_prerequisites: symlink into the source tree).
for dep in gmp mpfr mpc; do
  DEP_SRC=$(locate_root "${SRC_DIR}/${dep}-src" "configure")
  ln -sfn "${DEP_SRC}" "${GCC_SRC}/${dep}"
done

# ---------------------------------------------------------------------------
# binutils (linux only): bundled into the package like the Alire toolchains,
# so the compiler is self-contained. binutils also installs its tools under
# ${PREFIX}/<triplet>/bin/, which is where the gcc driver looks first.
# ---------------------------------------------------------------------------
if [[ "${target_platform}" == linux-* ]]; then
  BINUTILS_SRC=$(locate_root "${SRC_DIR}/binutils" "configure")
  mkdir -p "${SRC_DIR}/objdir-binutils"
  pushd "${SRC_DIR}/objdir-binutils"
  "${BINUTILS_SRC}/configure" \
    --prefix="${GNAT_PREFIX}" \
    --disable-gprofng \
    --disable-nls \
    --disable-werror
  make -j"${CPU_COUNT}"
  make install-strip
  popd
fi

# ---------------------------------------------------------------------------
# GCC with c,c++,ada
# Configure args follow alire-project/GNAT-FSF-builds specs/gcc.anod
# (the proven recipe for FSF GNAT), plus conda specifics.
# ---------------------------------------------------------------------------
CONFIGURE_ARGS=(
  --prefix="${GNAT_PREFIX}"
  --enable-languages=c,c++,ada
  --disable-bootstrap
  --disable-multilib
  --disable-nls
  --disable-libstdcxx-pch
  --enable-lto
  --enable-checking=release
  --without-libiconv-prefix
  --with-pkgversion="conda-forge gnat-bootstrap ${PKG_VERSION}"
  --with-bugurl="https://github.com/conda-forge/gnat-bootstrap-feedstock/issues"
)

if [[ "${target_platform}" == linux-* ]]; then
  CONFIGURE_ARGS+=(
    --enable-threads=posix
    --enable-default-pie
    --with-gnu-as
    --with-gnu-ld
    # Enable sysroot support (default: none) so that downstream recipes can
    # point the compiler at conda-forge's glibc sysroot via --sysroot to
    # target the usual glibc baseline instead of the build machine's.
    --with-sysroot=/
    --with-build-sysroot=/
  )
fi

if [[ "${target_platform}" == osx-* ]]; then
  CLT_SDK="/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
  XCODE_SDK="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
  # Build against the conda-forge SDK if set up, and default the installed
  # compiler's sysroot to whichever SDK exists on the user's machine
  # (overridable with -sysroot). Same trick as GNAT-FSF-builds.
  CONFIGURE_ARGS+=(
    --with-build-sysroot="${CONDA_BUILD_SYSROOT:-${CLT_SDK}}"
    "--with-specs=%{!-sysroot=*:--sysroot=%:if-exists-else(${CLT_SDK} ${XCODE_SDK})}"
  )
fi

mkdir -p "${SRC_DIR}/objdir"
cd "${SRC_DIR}/objdir"

"${GCC_SRC}/configure" "${CONFIGURE_ARGS[@]}"

make -j"${CPU_COUNT}"
make install-strip

# ---------------------------------------------------------------------------
# Slim down: docs and localization are dead weight for a build tool.
# ---------------------------------------------------------------------------
rm -rf "${GNAT_PREFIX}/share/man" "${GNAT_PREFIX}/share/info" \
       "${GNAT_PREFIX}/share/locale" "${GNAT_PREFIX}/share/doc"

# ---------------------------------------------------------------------------
# Activation: export GNAT_BOOTSTRAP_HOME (the GOROOT_BOOTSTRAP pattern from
# go1.4-bootstrap). PATH is deliberately left alone; consumers opt in with
#   export PATH="${GNAT_BOOTSTRAP_HOME}/bin:${PATH}"
# ---------------------------------------------------------------------------
mkdir -p "${PREFIX}/etc/conda/activate.d" "${PREFIX}/etc/conda/deactivate.d"
cat > "${PREFIX}/etc/conda/activate.d/gnat-bootstrap_activate.sh" <<'EOF'
export GNAT_BOOTSTRAP_HOME="${CONDA_PREFIX}/gnat-bootstrap"
EOF
cat > "${PREFIX}/etc/conda/deactivate.d/gnat-bootstrap_deactivate.sh" <<'EOF'
unset GNAT_BOOTSTRAP_HOME
EOF

# Sanity check: the freshly-built (not the seed's) gnatmake must work.
hash -r
export PATH="${GNAT_PREFIX}/bin:${PATH}"
command -v gnatmake | grep -F "${GNAT_PREFIX}"
cat > /tmp/conda_gnat_smoke.adb <<'EOF'
procedure Conda_Gnat_Smoke is
begin
   null;
end Conda_Gnat_Smoke;
EOF
pushd /tmp
gnatmake conda_gnat_smoke.adb
./conda_gnat_smoke
popd
