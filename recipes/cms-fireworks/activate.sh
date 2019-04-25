#!/usr/bin/env bash

# For ROOT
export ROOTSYS="${CONDA_PREFIX}"
# env vars expected by cmsShow
export CMSSW_RELEASE_BASE="${CONDA_PREFIX}"
export CMSSW_BASE="${CONDA_PREFIX}"
export OLD_DYLD_FALLBACK_LIBRARY_PATH=$DYLD_FALLBACK_LIBRARY_PATH
export DYLD_FALLBACK_LIBRARY_PATH="${CONDA_PREFIX}"/lib:$DYLD_FALLBACK_LIBRARY_PATH
export LIBRARY_PATH="${CONDA_PREFIX}"/lib
export ROOT_INCLUDE_PATH=${ROOT_INCLUDE_PATH}:${ROOTSYS}:"${CONDA_PREFIX}"/src
export CMSSW_SEARCH_PATH=${CONDA_PREFIX}

# Only on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Only if not in the base env (let's be nice)
    if [ "${CONDA_DEFAULT_ENV}"  != "base" ] ; then
        if [ -z "${CONDA_BUILD_SYSROOT}" ] ; then
            echo "WARNING: Compiling likely won't work unless you download the macOS 10.9 SDK and set CONDA_BUILD_SYSROOT."
            echo "You can probably ignore this warning and just omit + or ++ when executing ROOT macros."
        fi
    fi
fi
