#!/usr/bin/env bash
set -eu

# Set up binary directory
mkdir -p binary/bin _logs

# Create bash completion
mkdir -p "${PREFIX}"/etc/bash_completion.d

export MergeObjsCmd=${LD_GOLD:-${LD}}
export M4=${BUILD_PREFIX}/bin/m4
export PYTHON=${BUILD_PREFIX}/bin/python
export PATH=${BUILD_PREFIX}/ghc-bootstrap/bin${PATH:+:}${PATH:-}

"${RECIPE_DIR}"/building/build-"${target_platform}.sh"

# Create bash completion
mkdir -p "${PREFIX}"/etc/bash_completion.d
cp utils/completion/ghc.bash "${PREFIX}"/etc/bash_completion.d/ghc

# Clean up package cache
# Does this allow building Hello with inbedded HS libs and prevent segfault on linux and 4GB reloc on osx?
# find "${PREFIX}"/lib/*ghc-"${PKG_VERSION}" -name '*inplace.a' -delete
find "${PREFIX}"/lib/*ghc-"${PKG_VERSION}" -name '*_p.a' -delete
find "${PREFIX}"/lib/*ghc-"${PKG_VERSION}" -name '*.p_o' -delete

# Clean up package cache
rm -f "${PREFIX}"/lib/*ghc-"${PKG_VERSION}"/lib/package.conf.d/package.cache
rm -f "${PREFIX}"/lib/*ghc-"${PKG_VERSION}"/lib/package.conf.d/package.cache.lock

mkdir -p "${PREFIX}/etc/conda/activate.d"
cp "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"

# Cleanup potential hard-coded build env paths
if [[ -f "${PREFIX}"/lib/ghc-"${PKG_VERSION}"/lib/settings ]]; then
  perl -pi -e 's#($ENV{BUILD_PREFIX}|$ENV{PREFIX})/bin/##g' "${PREFIX}"/lib/ghc-"${PKG_VERSION}"/lib/settings
fi

# Find all the .dylib libs with the '-ghc9.12.2' extension and link them to non-'-ghc9.12.2'
find "${PREFIX}/lib" -name "*-ghc${PKG_VERSION}.dylib" -o -name "*-ghc${PKG_VERSION}.so" | while read -r lib; do
  base_lib="${lib//-ghc${PKG_VERSION}./.}"
  if [[ ! -e "$base_lib" ]]; then
    ln -s "$(basename "$lib")" "$base_lib"
  fi
done

# Add package licenses
arch="-${target_platform#*-}"
arch="${arch//-64/-x86_64}"
arch="${arch#*-}"
arch="${arch//arm64/aarch64}"
pushd "${PREFIX}/share/doc/${arch}-${target_platform%%-*}-ghc-${PKG_VERSION}-inplace" || true
  for file in */LICENSE; do
    cp "${file///-}" "${SRC_DIR}"/license_files
  done
popd
