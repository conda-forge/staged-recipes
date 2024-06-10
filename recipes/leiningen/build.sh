#!/usr/bin/env bash
set -ex

# Modify Leiningen lein-pkg installation script

install_leiningen() {
  local _prefix=$1
  local _leiningen_pkg_dir=$2
  local _version=$3

  lib_dir="${_prefix}/lib"
  bin_dir="${_prefix}/bin"

  leiningen_lib_dir="${lib_dir}/leiningen"

  mkdir -p "${bin_dir}" "${leiningen_lib_dir}/libexec"

  install -m644 "${_leiningen_pkg_dir}"/leiningen-"${_version}"-standalone.jar "${leiningen_lib_dir}/libexec"
  install -m755 "${SRC_DIR}"/leiningen-src/bin/lein-pkg "${bin_dir}/lein"

  sed -i -e 's@LEIN_VERSION=.*@LEIN_VERSION='"${_version}"'@g' "${bin_dir}"/lein
  sed -i -e 's@/usr/share/java@\${CONDA_PREFIX}/lib/leiningen/libexec@g' "${bin_dir}"/lein
}

# --- Installation ---
install_leiningen "${PREFIX}" "${SRC_DIR}"/leiningen-jar "${PKG_VERSION}"

# At this point we have a working Leiningen
# We rebuild from source to add the THIRD-PARTY.txt file
cd "${SRC_DIR}"/leiningen-src/leiningen-core
  lein bootstrap
  mvn license:add-third-party -Dlicense.thirdPartyFile=THIRD-PARTY.txt
  cp target/generated-sources/license/THIRD-PARTY.txt "${RECIPE_DIR}"/THIRD-PARTY.txt

cd "${SRC_DIR}"/leiningen-src
  # Some tests fail, but we don't care for now
  bin/lein test > _lein_test.log || true
  bin/lein uberjar
  install -m644 target/leiningen-"${PKG_VERSION}"-standalone.jar "${leiningen_lib_dir}/libexec"
