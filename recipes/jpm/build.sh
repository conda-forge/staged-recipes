#!/usr/bin/env bash

set -exuo pipefail

# conda-build provides PREFIX; reuse it for Janet's install prefix.
: "${PREFIX:?}"

export PREFIX
export JANET_PREFIX="${PREFIX}"
unset DESTDIR

libpath="${PREFIX}/lib"
headerpath="${PREFIX}/include/janet"
binpath="${PREFIX}/bin"
modpath="${PREFIX}/lib/janet"
manpath="${PREFIX}/share/man/man1"

target_platform="${target_platform:-$(uname | tr '[:upper:]' '[:lower:]')}"

declare -a janet_lflags dynamic_lflags
modext=".so"
statext=".a"

case "${target_platform}" in
  linux-*)
    janet_lflags=(-lm -ldl -lrt -pthread "-Wl,-rpath,${libpath}")
    dynamic_lflags=(-shared -lpthread)
    ;;
  osx-*|darwin*)
    modext=".so"
    janet_lflags=(-lm -ldl -pthread "-Wl,-export_dynamic" "-Wl,-rpath,${libpath}")
    dynamic_lflags=(-shared -undefined dynamic_lookup -lpthread)
    ;;
  *)
    janet_lflags=(-lm -ldl -pthread "-Wl,-rpath,${libpath}")
    dynamic_lflags=(-shared -lpthread)
    ;;
esac

join_vec() {
  local result=""
  for value in "$@"; do
    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    result="${result} \"${value}\""
  done
  echo "${result# }"
}

janet_lflags_literal=$(join_vec "${janet_lflags[@]}")
dynamic_lflags_literal=$(join_vec "${dynamic_lflags[@]}")

conda_config="configs/conda_config.janet"
cat > "${conda_config}" <<EOF
(def config
  {:ar "ar"
   :auto-shebang true
   :binpath "${binpath}"
   :c++ "c++"
   :c++-link "c++"
   :cc "cc"
   :cc-link "cc"
   :cflags @["-std=c99"]
   :cflags-verbose @[]
   :cppflags @["-std=c++11"]
   :curlpath "curl"
   :dynamic-cflags @["-fPIC"]
   :dynamic-lflags @[${dynamic_lflags_literal}]
   :gitpath "git"
   :headerpath "${headerpath}"
   :is-msvc false
   :janet "janet"
   :janet-cflags @[]
   :janet-lflags @[${janet_lflags_literal}]
   :ldflags @[]
   :lflags @[]
   :libpath "${libpath}"
   :manpath "${manpath}"
   :modext "${modext}"
   :modpath "${modpath}"
   :nocolor false
   :pkglist "https://github.com/janet-lang/pkgs.git"
   :silent false
   :statext "${statext}"
   :tarpath "tar"
   :test false
   :use-batch-shell false
   :verbose false})
EOF

janet bootstrap.janet "${conda_config}"
