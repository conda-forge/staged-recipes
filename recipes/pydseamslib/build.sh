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

mkdir -p subprojects
# Directory present: meson will not fetch seams-core.wrap.
if [[ -e subprojects/seams-core ]]; then
  rm -rf subprojects/seams-core
fi
mv "${SEAMS}" subprojects/seams-core
if [[ -e subprojects/seams-core.wrap ]]; then
  rm -f subprojects/seams-core.wrap
fi

# Optional git wraps: no network, no unused fetch.
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
if [[ -e subprojects/seams-core/subprojects/vesin.wrap ]]; then
  rm -f subprojects/seams-core/subprojects/vesin.wrap
fi

if [[ -e subprojects/seams-core/subprojects/linkcell ]]; then
  rm -rf subprojects/seams-core/subprojects/linkcell
fi
mv "${LINKCELL}" subprojects/seams-core/subprojects/linkcell
if [[ -e subprojects/seams-core/subprojects/linkcell.wrap ]]; then
  rm -f subprojects/seams-core/subprojects/linkcell.wrap
fi
if [[ -e subprojects/linkcell.wrap ]]; then
  rm -f subprojects/linkcell.wrap
fi

# Compile nanobind with the wrap overlay (Py_LIMITED_API). Do not use
# the conda-forge nanobind package: that is a full-API build.
if [[ -e subprojects/nanobind-2.14.0 ]]; then
  rm -rf subprojects/nanobind-2.14.0
fi
mv "${NANOBIND}" subprojects/nanobind-2.14.0
# nanobind.wrap stays: directory present, so meson applies
# packagefiles/nanobind and does not fetch.

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
# GNU ld flags break the osx clang++ compiler check.
if [[ "$(uname)" == Linux ]]; then
  export LDFLAGS="${LDFLAGS:-} -pthread -Wl,--no-as-needed -lblas -llapack -lgomp -Wl,--as-needed -Wl,-rpath,${PREFIX}/lib"
else
  export LDFLAGS="${LDFLAGS:-} -pthread"
fi

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation

if [[ "$(uname)" == Linux ]] && command -v patchelf >/dev/null 2>&1; then
  shopt -s nullglob
  for so in "${PREFIX}"/lib/python3.1[2-9]/site-packages/pydseams/yoda*.so; do
    patchelf --remove-rpath "${so}" || true
    patchelf --force-rpath --set-rpath "\$ORIGIN/../../.." "${so}"
  done
fi
