#!/usr/bin/env bash

# For ROOT
export ROOTSYS="${CONDA_PREFIX}"
# env vars expected by cmsShow
export CMSSW_RELEASE_BASE=""
export CMSSW_BASE="${CONDA_PREFIX}"
export CMSSW_SEARCH_PATH=${CONDA_PREFIX}/data
export CMSSW_DATA_PATH=${CONDA_PREFIX}/data
export CMSSW_RELEASE CMSSW_10_5_0
# Only on macOS
if [[ "$(uname)" == "Darwin" ]]; then
    # Only if not in the base env (let's be nice)
    if [ "${CONDA_DEFAULT_ENV}"  != "base" ] ; then
        if [ -z "${CONDA_BUILD_SYSROOT}" ] ; then
            echo "WARNING: Compiling likely won't work unless you download the macOS 10.9 SDK and set CONDA_BUILD_SYSROOT."
            echo "You can probably ignore this warning and just omit + or ++ when executing ROOT macros."
        fi
    fi
    export OLD_DYLD_FALLBACK_LIBRARY_PATH=$DYLD_FALLBACK_LIBRARY_PATH
    export DYLD_FALLBACK_LIBRARY_PATH="${CONDA_PREFIX}"/lib:$DYLD_FALLBACK_LIBRARY_PATH
    export ROOT_INCLUDE_PATH="${CONDA_PREFIX}"/src:"${CONDA_PREFIX}"/include:${CONDA_BUILD_SYSROOT}/usr/include
else
    export OLD_LD_LIBRARY_PATH=$LD_LIBRARY_PATH
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${CONDA_PREFIX}/lib
    export ROOT_INCLUDE_PATH="${CONDA_PREFIX}"/src:"${CONDA_PREFIX}"/include
fi
alias cmsShow='cmsShow.exe'

if [ ! -e ${CONDA_PREFIX}/.pch-regenerated ]; then
  cd ${CONDA_PREFIX}
  echo 'Regenerating ${CONDA_PREFIX}/etc/allDict.cxx.pch on first activation.'
  ROOTIGNOREPREFIX=1 python etc/dictpch/makepch.py etc/allDict.cxx.pch -I./include
  echo 'Done'
  date >.pch-regenerated
  cd - 2>/dev/null
fi
