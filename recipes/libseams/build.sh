#!/usr/bin/env bash
# Build libyodaLib, libseams, libseams_lang, and the seams command.
set -euxo pipefail

# conda-forge's compiler activation sets MESON_ARGS (prefix, libdir,
# buildtype, and the cross file when cross-compiling).
if [[ -z "${MESON_ARGS:-}" ]]; then
  MESON_ARGS="-Dbuildtype=release --prefix=${PREFIX} -Dlibdir=lib"
fi

# Eigen, Highway and linkcell are conda-forge packages. Backends with
# no conda-forge build, or whose newest upstream release is still the
# broken one, stay off. nodownload makes a missing subproject an error
# instead of a fetch.
# shellcheck disable=SC2086
meson setup build ${MESON_ARGS} \
  --wrap-mode=nodownload \
  -Ddefault_library=shared \
  -Dwith_tests=false \
  -Dwith_cli=true \
  -Dwith_blas=disabled \
  -Dwith_chemfiles=disabled \
  -Dwith_readcon=disabled \
  -Dwith_linkcell=enabled \
  -Dwith_minimage=disabled \
  -Dwith_gpulite=disabled \
  -Dwith_openmp_offload=disabled \
  -Dwith_mpi=disabled \
  -Dwith_lammps=disabled \
  -Dwith_gromacs=disabled \
  -Dwith_openmm=disabled \
  -Dwith_plumed=disabled \
  -Dwith_ira=disabled \
  -Dwith_sphericart=disabled \
  -Dwith_csm=disabled \
  -Dwith_spglib=disabled \
  -Dwith_nauty=disabled

meson compile -C build -j "${CPU_COUNT:-2}"
meson install -C build --no-rebuild
