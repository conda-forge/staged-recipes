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

# The recipe declares the conda-forge C and C++ compiler packages for host+run,
# so CC/CXX/AR must point at those wrapped toolchains. Fail fast with clear
# guidance if something is misconfigured.
if [[ -z "${CC:-}" ]]; then
  echo "error: CC is unset. The conda-forge compiler('c') package should set it." >&2
  exit 1
fi
cc_bin="${CC}"
if ! command -v "${cc_bin}" >/dev/null 2>&1; then
  echo "error: C compiler '${cc_bin}' from CC is not on PATH." >&2
  exit 1
fi

if [[ -z "${CXX:-}" ]]; then
  echo "error: CXX is unset. The recipe expects compiler('cxx') to provide it." >&2
  exit 1
fi
cxx_bin="${CXX}"
if ! command -v "${cxx_bin}" >/dev/null 2>&1; then
  echo "error: C++ compiler '${cxx_bin}' from CXX is not on PATH." >&2
  exit 1
fi

if [[ -z "${AR:-}" ]]; then
  echo "error: AR is unset. The compiler packages should export it." >&2
  exit 1
fi
ar_bin="${AR}"
if ! command -v "${ar_bin}" >/dev/null 2>&1; then
  echo "error: Archiver '${ar_bin}' from AR is not on PATH." >&2
  exit 1
fi

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
  {:ar "${ar_bin}"
   :auto-shebang true
   :binpath "${binpath}"
   :c++ "${cxx_bin}"
   :c++-link "${cxx_bin}"
   :cc "${cc_bin}"
   :cc-link "${cc_bin}"
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
