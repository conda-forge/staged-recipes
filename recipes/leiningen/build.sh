#!/usr/bin/env bash
set -ex

# Modify Leiningen lein-pkg installation script

install_leiningen() {
  local _prefix=$1
  local _leiningen_pkg_dir=$2
  local _version=$3

  lib_dir="$_prefix/lib"
  bin_dir="$_prefix/bin"

  leiningen_lib_dir="$lib_dir/leiningen"

  mkdir -p "$bin_dir" "$leiningen_lib_dir/libexec"

  install -m644 $_leiningen_pkg_dir/leiningen-${_version}-standalone.jar "$leiningen_lib_dir/libexec"
  install -m755 $SRC_DIR/leiningen-src/bin/lein-pkg "$bin_dir/lein"

  sed -i -e 's@LEIN_VERSION=.*@LEIN_VERSION='"$_version"'@g' $bin_dir/lein
  sed -i -e 's@/usr/share/java@\${CONDA_PREFIX}/lib/leiningen/libexec@g' $bin_dir/lein
}

# --- Installation ---
install_leiningen $PREFIX $SRC_DIR/leiningen-jar $PKG_VERSION

# At this point we have a working Leiningen
# We could now build from source, however, it seems unnecessary
# cd $SRC_DIR/leiningen-src/leiningen-core
#   lein bootstrap
#
# cd $SRC_DIR/leiningen-src
#   bin/lein test
#   bin/lein uberjar
