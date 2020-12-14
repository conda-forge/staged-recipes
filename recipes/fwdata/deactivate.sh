#!/usr/bin/env bash

unset CMSSW_RELEASE_BASE
unset CMSSW_BASE
unset CMSSW_SEARCH_PATH
unset CMSSW_DATA_PATH
unset CMSSW_VERSION

if [[ "$(uname)" == "Darwin" ]]; then
  unset DYLD_FALLBACK_LIBRARY_PATH
else
  unset LD_LIBRARY_PATH
fi
unset ROOT_INCLUDE_PATH
