#!/bin/bash

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

# When people are using conda-build, assume that adding rpath during build, and pointing at
#    the host env's includes and libs is helpful default behavior
if [ "${CONDA_BUILD:-0}" = "1" ]; then
  CFLAGS_USED="@CFLAGS@ -I${PREFIX}/include -fdebug-prefix-map=${SRC_DIR}=/usr/local/src/conda/${PKG_NAME}-${PKG_VERSION} -fdebug-prefix-map=${PREFIX}=/usr/local/src/conda-prefix"
  DEBUG_CFLAGS_USED="@DEBUG_CFLAGS@ -I${PREFIX}/include -fdebug-prefix-map=${SRC_DIR}=/usr/local/src/conda/${PKG_NAME}-${PKG_VERSION} -fdebug-prefix-map=${PREFIX}=/usr/local/src/conda-prefix"
  LDFLAGS_USED="@LDFLAGS@ -Wl,-rpath,${PREFIX}/lib -Wl,-rpath-link,${PREFIX}/lib -L${PREFIX}/lib"
  CPPFLAGS_USED="@CPPFLAGS@ -I${PREFIX}/include"
  DEBUG_CPPFLAGS_USED="@DEBUG_CPPFLAGS@ -I${PREFIX}/include"
  CMAKE_PREFIX_PATH_USED="${CMAKE_PREFIX_PATH}:${PREFIX}:${BUILD_PREFIX}/${HOST}/sysroot/usr"
else
  CFLAGS_USED="@CFLAGS@"
  DEBUG_CFLAGS_USED="@DEBUG_CFLAGS@"
  CPPFLAGS_USED="@CPPFLAGS@"
  DEBUG_CPPFLAGS_USED="@DEBUG_CPPFLAGS@"
  LDFLAGS_USED="@LDFLAGS@"
fi

if [ "${CONDA_BUILD:-0}" = "1" ]; then
  if [ -f /tmp/old-env-$$.txt ]; then
    rm -f /tmp/old-env-$$.txt || true
  fi
  env > /tmp/old-env-$$.txt
fi

_CONDA_PYTHON_SYSCONFIGDATA_NAME_USED=${_CONDA_PYTHON_SYSCONFIGDATA_NAME:-@_CONDA_PYTHON_SYSCONFIGDATA_NAME@}
if [ -n "${_CONDA_PYTHON_SYSCONFIGDATA_NAME_USED}" ] && [ -n "${SYS_SYSROOT}" ]; then
  if find "$(dirname $(dirname ${SYS_PYTHON}))/lib/"python* -type f -name "${_CONDA_PYTHON_SYSCONFIGDATA_NAME_USED}.py" -exec false {} +; then
    echo ""
    echo "WARNING: The Python interpreter at the following prefix:"
    echo "         $(dirname $(dirname ${SYS_PYTHON}))"
    echo "         .. is not able to handle sysconfigdata-based compilation for the host:"
    echo "         ${_CONDA_PYTHON_SYSCONFIGDATA_NAME_USED//_sysconfigdata_/}"
    echo ""
    echo "         We are not preventing things from continuing here, but *this* Python will not"
    echo "         be able to compile software for this host, and, depending on whether it has"
    echo "         been patched to ignore missing _CONDA_PYTHON_SYSCONFIGDATA_NAME or not, may cause"
    echo "         an exception."
    echo ""
    echo "         This can happen for one of three reasons:"
    echo ""
    echo "         1. It is out of date: Please run 'conda update python' in that environment"
    echo ""
    echo "         2. You are bootstrapping a sysconfigdata-based cross-capable Python and can ignore this"
    echo "            (but please remember to copy the generated sysconfigdata back to the Python recipe's"
    echo "             sysconfigdate folder and then rebuild it for all the systems you want to be able"
    echo "             to use as a build machine for this host)."
    echo ""
    echo "         3. You are attempting your own bespoke cross-compilation host that is not supported. Have"
    echo "            you provided your own value in the _CONDA_PYTHON_SYSCONFIGDATA_NAME environment variable but"
    echo "            misspelt it and/or failed to add the neccessary ${_CONDA_PYTHON_SYSCONFIGDATA_NAME_USED}.py"
    echo "            file to the Python interpreter's standard library?"
    echo ""
  fi
fi

_tc_activation \
  activate host @CHOST@ @CHOST@- \
  cc cpp gcc gcc-ar gcc-nm gcc-ranlib \
  "CPPFLAGS,${CPPFLAGS:-${CPPFLAGS_USED}}" \
  "CFLAGS,${CFLAGS:-${CFLAGS_USED}}" \
  "LDFLAGS,${LDFLAGS:-${LDFLAGS_USED}}" \
  "DEBUG_CPPFLAGS,${DEBUG_CPPFLAGS:-${DEBUG_CPPFLAGS_USED}}" \
  "DEBUG_CFLAGS,${DEBUG_CFLAGS:-${DEBUG_CFLAGS_USED}}" \
  "CMAKE_PREFIX_PATH,${CMAKE_PREFIX_PATH:-${CMAKE_PREFIX_PATH_USED}}" \
  "_CONDA_PYTHON_SYSCONFIGDATA_NAME,${_CONDA_PYTHON_SYSCONFIGDATA_NAME_USED}"

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
