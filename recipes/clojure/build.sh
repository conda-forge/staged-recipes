#!/usr/bin/env bash
set -ex

# --- Functions ---
install_clojure() {
  local _prefix=$1
  local _clojure_pkg_dir=$2

  lib_dir="$_prefix/lib"
  bin_dir="$_prefix/bin"
  man_dir="$_prefix/share/man/man1"

  clojure_lib_dir="$lib_dir/clojure"

  mkdir -p "$bin_dir" "$clojure_lib_dir/libexec" "$man_dir"

  install -m644 "$_clojure_pkg_dir"/deps.edn "$clojure_lib_dir/deps.edn"
  install -m644 "$_clojure_pkg_dir"/example-deps.edn "$clojure_lib_dir/example-deps.edn"
  install -m644 "$_clojure_pkg_dir"/tools.edn "$clojure_lib_dir/tools.edn"

  # install -m644 "$_clojure_pkg_dir"/clojure-tools-*\.*\.*\.*\.jar "$clojure_lib_dir/libexec/clojure-tools-${_version}.jar"
  install -m644 "$_clojure_pkg_dir"/clojure-tools-*\.*\.*\.*\.jar "$clojure_lib_dir/libexec/"
  install -m644 "$_clojure_pkg_dir"/exec.jar "$clojure_lib_dir/libexec/exec.jar"

  install -m755 "$_clojure_pkg_dir"/clojure "$bin_dir/clojure"
  install -m755 "$_clojure_pkg_dir"/clj "$bin_dir/clj"
  sed -i -e 's@PREFIX@'"$clojure_lib_dir"'@g' "$bin_dir"/clojure
  sed -i -e 's@BINDIR@'"$bin_dir"'@g' "$bin_dir"/clj
  # sed -i -e 's@version=.*@version='"${_version}"'@g' "$bin_dir"/clojure

  install -m644 "$_clojure_pkg_dir"/clojure.1 "$man_dir/clojure.1"
  install -m644 "$_clojure_pkg_dir"/clj.1 "$man_dir/clj.1"
}

extract_licenses() {
  local _clojure_src=$1

  cp "${_clojure_src}"/epl-v10.html "${RECIPE_DIR}"
  cd "${_clojure_src}" && mvn license:add-third-party -DlicenseFile=THIRD-PARTY.txt > _clojure-license.log 2>&1
  cp "${_clojure_src}"/target/generated-sources/license/THIRD-PARTY.txt "${RECIPE_DIR}"
  ls "${RECIPE_DIR}"/{THIRD-PARTY.txt,epl-v10.html} || { echo "Failed to extract licenses"; exit 1; }
}

build_clojure_from_source() {
  local _clojure_src=$1
  local _build_dir=$2

  local current_dir
  current_dir=$(pwd)

  mkdir -p "${_build_dir}"
  cd "${_build_dir}"
    cp -r "${_clojure_src}"/* .
    mvn -Dmaven.test.skip=true package > _clojure-build.log 2>&1
    mvn install:install-file -Dfile=target/clojure-"${PKG_SRC_VERSION}".jar -DgroupId=org.clojure -DartifactId=clojure -Dversion="${PKG_SRC_VERSION}" -Dpackaging=jar > _clojure-maven-install.log 2>&1
cd "$current_dir"
}

build_clojure_from_tools() {
  local _clojure_tools_src=$1
  local _build_dir=$2

  local current_dir
  current_dir=$(pwd)

  mkdir -p "${_build_dir}"
  cd "${_build_dir}"
    cp -r "${_clojure_tools_src}"/* .

    export VERSION="${PKG_SRC_VERSION}"
    "${SRC_DIR}"/_conda-bootstrapped/bin/clojure -T:build release > _clojure-tools-build.log 2>&1
  cd "$current_dir"
}

# --- Installation bootstrap, licenses, clojure, clojure-tools, install ---
install_clojure "${SRC_DIR}"/_conda-bootstrapped "$SRC_DIR"/clojure-tools
extract_licenses "$SRC_DIR"/clojure-src
build_clojure_from_source "$SRC_DIR"/clojure-src "$SRC_DIR"/_conda-clojure-build
build_clojure_from_tools "$SRC_DIR"/clojure-tools-src "$SRC_DIR"/_conda-tools-build
install_clojure "$PREFIX" "$SRC_DIR"/_conda-tools-build/target/clojure-tools
