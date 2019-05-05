#!/usr/bin/env csh

unsetenv CMSSW_RELEASE_BASE
unsetenv CMSSW_BASE
unsetenv CMSSW_SEARCH_PATH
unsetenv CMSSW_DATA_PATH
unsetenv CMSSW_RELEASE

if [[ "$(uname)" == "Darwin" ]]; then
  unsetenv DYLD_FALLBACK_LIBRARY_PATH
else
  unsetenv LD_LIBRARY_PATH
fi
unsetenv ROOT_INCLUDE_PATH
