#!/usr/bin/env bash
# Place tagged tarballs where meson expects subprojects. Do not use
# wrap-git (no clone on the conda-forge builder).
set -euxo pipefail

# First source is the pydseamslib sdist (SRC_DIR). Extra archives unpack
# under target_directory, each with a GitHub top-level folder.
find_tree() {
  local root="$1"
  local marker="$2"
  if [[ -f "${root}/${marker}" ]]; then
    printf '%s\n' "${root}"
    return
  fi
  local hit
  hit=$(find "${root}" -mindepth 1 -maxdepth 2 -type f -name "${marker}" | head -n 1)
  if [[ -n "${hit}" ]]; then
    dirname "${hit}"
    return
  fi
  echo "could not find ${marker} under ${root}" >&2
  exit 1
}

SEAMS=$(find_tree _src_seams meson.build)
VESIN=$(find_tree _src_vesin vesin/src/vesin.cpp)
LINKCELL=$(find_tree _src_linkcell meson.build)
NANOBIND=$(find_tree _src_nanobind include/nanobind/nanobind.h)
ROBIN=$(find_tree _src_robin_map include/tsl/robin_map.h)

# License files harvested from SRC_DIR after the script; copy before mv.
cp "${SEAMS}/LICENSE" LICENSE-seams-core
cp "${VESIN}/LICENSE" LICENSE-vesin
cp "${LINKCELL}/LICENSE" LICENSE-linkcell
cp "${NANOBIND}/LICENSE" LICENSE-nanobind
cp "${ROBIN}/LICENSE" LICENSE-robin-map

# Rust crate licenses for the linkcell static/cdylib (rayon and so on).
(
  cd "${LINKCELL}"
  cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml"
)

mkdir -p subprojects
# Directory present: meson will not fetch seams-core.wrap.
if [[ -e subprojects/seams-core ]]; then
  rm -rf subprojects/seams-core
fi
mv "${SEAMS}" subprojects/seams-core
if [[ -e subprojects/seams-core.wrap ]]; then
  rm -f subprojects/seams-core.wrap
fi

# Optional git wraps: no network, no unused fetch. readcon-core stays off.
for wrap in readcon-core.wrap gpulite.wrap; do
  if [[ -e "subprojects/seams-core/subprojects/${wrap}" ]]; then
    rm -f "subprojects/seams-core/subprojects/${wrap}"
  fi
done

if [[ -e subprojects/seams-core/subprojects/vesin ]]; then
  rm -rf subprojects/seams-core/subprojects/vesin
fi
mv "${VESIN}" subprojects/seams-core/subprojects/vesin
# packagefiles/vesin is the Meson wrap overlay (CPU + CUDA stub).
cp subprojects/seams-core/subprojects/packagefiles/vesin/meson.build \
  subprojects/seams-core/subprojects/vesin/meson.build
cp subprojects/seams-core/subprojects/packagefiles/vesin/vesin_cuda_stub.cpp \
  subprojects/seams-core/subprojects/vesin/vesin_cuda_stub.cpp
# Local wrap-file: meson can fall back without cloning.
cat > subprojects/seams-core/subprojects/vesin.wrap <<'EOF'
[wrap-file]
directory = vesin

[provide]
vesin = vesin_dep
EOF

if [[ -e subprojects/seams-core/subprojects/linkcell ]]; then
  rm -rf subprojects/seams-core/subprojects/linkcell
fi
mv "${LINKCELL}" subprojects/seams-core/subprojects/linkcell
cat > subprojects/seams-core/subprojects/linkcell.wrap <<'EOF'
[wrap-file]
directory = linkcell

[provide]
linkcell = linkcell_dep
EOF
if [[ -e subprojects/linkcell.wrap ]]; then
  rm -f subprojects/linkcell.wrap
fi

# Compile nanobind with the wrap overlay (Py_LIMITED_API). Do not use
# the conda-forge nanobind package: that is a full-API build.
if [[ -e subprojects/nanobind-2.14.0 ]]; then
  rm -rf subprojects/nanobind-2.14.0
fi
mv "${NANOBIND}" subprojects/nanobind-2.14.0
# Directory present means meson will not apply wrap patch_directory.
# Install the limited-API overlay ourselves.
if [[ -f subprojects/packagefiles/nanobind/meson.build ]]; then
  cp subprojects/packagefiles/nanobind/meson.build \
    subprojects/nanobind-2.14.0/meson.build
fi
cat > subprojects/nanobind.wrap <<'EOF'
[wrap-file]
directory = nanobind-2.14.0

[provide]
dependency_names = nanobind
EOF

if [[ -e subprojects/robin-map-1.4.0 ]]; then
  rm -rf subprojects/robin-map-1.4.0
fi
mv "${ROBIN}" subprojects/robin-map-1.4.0
cat > subprojects/robin-map-1.4.0/meson.build <<'EOF'
project('robin-map', 'cpp', version: '1.4.0', meson_version: '>=1.0.0')
robin_map_dep = declare_dependency(
  include_directories: include_directories('include'),
)
meson.override_dependency('robin-map', robin_map_dep)
meson.override_dependency('tsl-robin-map', robin_map_dep)
EOF
cat > subprojects/robin-map.wrap <<'EOF'
[wrap-file]
directory = robin-map-1.4.0

[provide]
robin-map = robin_map_dep
dependency_names = robin-map, tsl-robin-map
EOF

export CXXFLAGS="${CXXFLAGS:-} -pthread"
export LDFLAGS="${LDFLAGS:-} -pthread"
# Do not force -lblas -llapack -lgomp. Meson finds BLAS; on
# conda-forge that is the libblas ABI (OpenBLAS today). Forcing
# libgomp onto the pthreads OpenBLAS backend mixes two runtimes.

# Do not pass --wrap-mode=nofallback: dependency('nanobind') and the
# seams-core vesin/linkcell fallbacks resolve through the local wraps
# above. nofallback ignores those wraps and the configure dies.
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation \
  -Csetup-args=-Dseams-core:with_python=false \
  -Csetup-args=-Dseams-core:with_tests=false \
  -Csetup-args=-Dseams-core:with_cli=false \
  -Csetup-args=-Dseams-core:with_lua=disabled \
  -Csetup-args=-Dseams-core:with_gpulite=disabled \
  -Csetup-args=-Dseams-core:with_ira=disabled \
  -Csetup-args=-Dseams-core:with_sphericart=disabled \
  -Csetup-args=-Dseams-core:with_nauty=disabled \
  -Csetup-args=-Dseams-core:with_mpi=disabled \
  -Cinstall-args=--skip-subprojects

if [[ "$(uname)" == Linux ]] && command -v patchelf >/dev/null 2>&1; then
  shopt -s nullglob
  for so in "${PREFIX}"/lib/python3.1[2-9]/site-packages/pydseams/yoda*.so; do
    patchelf --remove-rpath "${so}" || true
    patchelf --force-rpath --set-rpath "\$ORIGIN/../../.." "${so}"
  done
fi
