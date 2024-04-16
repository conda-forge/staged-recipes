#!/usr/bin/env bash
set -ex

# --- Functions ---
install_clojure() {
  local _prefix=$1
  local _clojure_pkg_dir=$2
  local _version=$3
  local _build=$4

  lib_dir="$_prefix/lib"
  bin_dir="$_prefix/bin"
  man_dir="$_prefix/share/man/man1"

  clojure_lib_dir="$lib_dir/clojure"

  mkdir -p "$bin_dir" "$clojure_lib_dir/libexec" "$man_dir"

  install -m644 $_clojure_pkg_dir/deps.edn "$clojure_lib_dir/deps.edn"
  install -m644 $_clojure_pkg_dir/example-deps.edn "$clojure_lib_dir/example-deps.edn"
  install -m644 $_clojure_pkg_dir/tools.edn "$clojure_lib_dir/tools.edn"

  install -m644 $_clojure_pkg_dir/clojure-tools-*\.*\.*\.*\.jar "$clojure_lib_dir/libexec/clojure-tools-${_version}.${_build}.jar"
  install -m644 $_clojure_pkg_dir/exec.jar "$clojure_lib_dir/libexec/exec.jar"

  install -m755 $_clojure_pkg_dir/clojure "$bin_dir/clojure"
  install -m755 $_clojure_pkg_dir/clj "$bin_dir/clj"
  sed -i -e 's@PREFIX@'"$clojure_lib_dir"'@g' $bin_dir/clojure
  sed -i -e 's@BINDIR@'"$bin_dir"'@g' $bin_dir/clj
  sed -i -e 's@version=.*@version='"${_version}.${_build}"'@g' $bin_dir/clojure

  install -m644 $_clojure_pkg_dir/clojure.1 "$man_dir/clojure.1"
  install -m644 $_clojure_pkg_dir/clj.1 "$man_dir/clj.1"
}

# --- Installation ---
install_clojure $PREFIX $SRC_DIR/clojure-tools $PKG_VERSION $PKG_BUILD
