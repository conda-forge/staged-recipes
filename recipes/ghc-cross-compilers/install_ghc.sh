#!/usr/bin/env bash
set -eu

pushd "${SRC_DIR}"/cross_install
  # Remove artifacts potentially conflicting with native GHC
  rm -f bin/hsc2hs-ghc-"${PKG_VERSION}"
  
  # Clean up package cache
  rm -f lib/*ghc-"${PKG_VERSION}"/lib/package.conf.d/package.cache
  rm -f lib/*ghc-"${PKG_VERSION}"/lib/package.conf.d/package.cache.lock

  # Cleanup potential hard-coded build env paths
  if [[ -f lib/ghc-"${PKG_VERSION}"/lib/settings ]]; then
    perl -pi -e 's#($ENV{BUILD_PREFIX}|$ENV{PREFIX})/bin/##g' lib/*ghc-"${PKG_VERSION}"/lib/settings
  fi

  # Find all the dynamic libs with the '-ghc*' extension and link them to non-'-ghc*'
  find lib -name "*-ghc${PKG_VERSION}.dylib" -o -name "*-ghc${PKG_VERSION}.so" | while read -r lib; do
    base_lib="${lib//-ghc${PKG_VERSION}./.}"
    if [[ ! -e "$base_lib" ]]; then
      ln -s "$(basename "$lib")" "$base_lib"
    fi
  done

  # Add package licenses
  if [[ "${PKG_VERSION}" != "9.6.7" ]]; then
    arch="-${cross_target_platform#*-}"
    arch="${arch//-64/-x86_64}"
    arch="${arch#*-}"
    arch="${arch//arm64/aarch64}"
    arch="${arch//ppc64le/powerpc64le}"
    pushd "share/doc/${arch}-${target_platform%%-*}-ghc-${PKG_VERSION}-inplace" || true
      for file in */LICENSE; do
        cp "${file///-}" "${SRC_DIR}"/license_files
      done
    popd
  fi
  
  # Move to PREFIX
  tar cf - ./* | (cd ${PREFIX}; tar xf -)
popd

mkdir -p "${PREFIX}/etc/conda/activate.d"
cp "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"

sed -i.bak "s|@CHOST@|${triplet}|g" "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"
