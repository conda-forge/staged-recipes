#!/bin/bash

[ -z "${CI}" ] || export CONDA_BUILD_WINSDK=/tmp/cf-ci-winsdk

# This function takes no arguments
# It tries to determine the name of this file in a programatic way.
function _get_sourced_filename() {
    if [ -n "${BASH_SOURCE[0]}" ]; then
        basename "${BASH_SOURCE[0]}"
    elif [ -n "${(%):-%x}" ]; then
        # in zsh use prompt-style expansion to introspect the same information
        # see http://stackoverflow.com/questions/9901210/bash-source0-equivalent-in-zsh
        basename "${(%):-%x}"
    else
        echo "UNKNOWN FILE"
    fi
}

# The arguments to this are:
# 1. activation nature {activate|deactivate}
# 2. toolchain nature {build|host|ccc}
# 3. machine (should match -dumpmachine)
# 4. prefix (including any final -)
# 5+ program (or environment var comma value)
# The format for 5+ is name{,,value}. If value is specified
#  then name taken to be an environment variable, otherwise
#  it is taken to be a program. In this case, which is used
#  to find the full filename during activation. The original
#  value is stored in environment variable CONDA_BACKUP_NAME
#  For deactivation, the distinction is irrelevant as in all
#  cases NAME simply gets reset to CONDA_BACKUP_NAME.  It is
#  a fatal error if a program is identified but not present.
function _tc_activation() {
  local act_nature=$1; shift
  local tc_nature=$1; shift
  local tc_machine=$1; shift
  local tc_prefix=$1; shift
  local thing
  local newval
  local from
  local to
  local pass

  if [ "${act_nature}" = "activate" ]; then
    from=""
    to="CONDA_BACKUP_"
  else
    from="CONDA_BACKUP_"
    to=""
  fi

  for pass in check apply; do
    for thing in $tc_nature,$tc_machine "$@"; do
      case "${thing}" in
        *,*)
          newval=$(echo "${thing}" | sed "s,^[^\,]*\,\(.*\),\1,")
          thing=$(echo "${thing}" | sed "s,^\([^\,]*\)\,.*,\1,")
          ;;
        *)
          newval="${CONDA_PREFIX}/bin/${tc_prefix}${thing}"
          if [ ! -x "${newval}" -a "${pass}" = "check" ]; then
            echo "ERROR: This cross-compiler package contains no program ${newval}"
            return 1
          fi
          ;;
      esac
      if [ "${pass}" = "apply" ]; then
        thing=$(echo ${thing} | tr 'a-z+-' 'A-ZX_')
        eval oldval="\$${from}$thing"
        if [ -n "${oldval}" ]; then
          eval export "${to}'${thing}'=\"${oldval}\""
        else
          eval unset '${to}${thing}'
        fi
        if [ -n "${newval}" ]; then
          eval export "'${from}${thing}=${newval}'"
        else
          eval unset '${from}${thing}'
        fi
      fi
    done
  done
  return 0
}

if [ "${CONDA_BUILD_WINSDK}" = "" ]; then
    echo "ERROR: CONDA_BUILD_WINSDK has to be set for cross-compiling"
fi

if [ "${CONDA_BUILD:-0}" = "1" ]; then
  if [ -f /tmp/old-env-$$.txt ]; then
    rm -f /tmp/old-env-$$.txt || true
  fi
  env > /tmp/old-env-$$.txt
fi

if [ "${CONDA_BUILD:-0}" = "1" ]; then
  INCLUDE_USED="${PREFIX}/include"
  LIB_USED="${PREFIX}/lib"
else
  INCLUDE_USED="${CONDA_PREFIX}/include"
  LIB_USED="${CONDA_PREFIX}/lib"
fi

WINSDK_INCLUDE=${CONDA_BUILD_WINSDK}/winsdk-@WINSDK_VERSION@/Include
WINSDK_LIB=${CONDA_BUILD_WINSDK}/winsdk-@WINSDK_VERSION@/Lib
MSVC_INCLUDE=${CONDA_BUILD_WINSDK}/msvc-@MSVC_HEADERS_VERSION@/include
MSVC_LIB=${CONDA_BUILD_WINSDK}/msvc-@MSVC_HEADERS_VERSION@/lib
INCLUDE_USED="${INCLUDE_USED};${MSVC_INCLUDE};${WINSDK_INCLUDE}/ucrt;${WINSDK_INCLUDE}/shared;${WINSDK_INCLUDE}/um;${WINSDK_INCLUDE}/winrt"
LIB_USED="${LIB_USED};${WINSDK_LIB}/ucrt/x64;${WINSDK_LIB}/um/x64;${MSVC_LIB}/x64"
CPPFLAGS_USED="-D_CRT_SECURE_NO_WARNINGS -D_MT -D_DLL --target=@CHOST@ -nostdlib -Xclang --dependent-lib=msvcrt -fuse-ld=lld"
LDFLAGS_USED="--target=@CHOST@ -nostdlib -Xclang --dependent-lib=msvcrt -fuse-ld=lld"

_tc_activation \
  activate host @CHOST@ @CHOST@- \
  as clang clang++ \
  "CC,${CC:-@CHOST@-clang}" \
  "CXX,${CXX:-@CHOST@-clang++}" \
  "LD,${LD-$(which lld-link)}" \
  "AR,${AR-$(which llvm-ar)}" \
  "RANLIB,${RANLIB-$(which llvm-ranlib)}" \
  "NM,${NM-$(which llvm-nm)}" \
  "CPPFLAGS,${CPPFLAGS_USED}" \
  "CFLAGS,${CPPFLAGS_USED}" \
  "CXXFLAGS,${CPPFLAGS_USED}" \
  "LDFLAGS,${LDFLAGS_USED}" \
  "LIB,${LIB_USED}" \
  "INCLUDE,${INCLUDE_USED}" \
  "CMAKE_PREFIX_PATH,${INCLUDE_USED};${LIB_USED}" \
  "CONDA_BUILD_CROSS_COMPILATION,1" \
  "lt_cv_deplibs_check_method,pass_all" \

if [ $? -ne 0 ]; then
  echo "ERROR: $(_get_sourced_filename) failed, see above for details"
else
  if [ "${CONDA_BUILD:-0}" = "1" ]; then
    if [ -f /tmp/new-env-$$.txt ]; then
      rm -f /tmp/new-env-$$.txt || true
    fi
    env > /tmp/new-env-$$.txt

    echo "INFO: $(_get_sourced_filename) made the following environmental changes:"
    diff -U 0 -rN /tmp/old-env-$$.txt /tmp/new-env-$$.txt | tail -n +4 | grep "^-.*\|^+.*" | grep -v "CONDA_BACKUP_" | sort
    rm -f /tmp/old-env-$$.txt /tmp/new-env-$$.txt || true
  fi
fi
