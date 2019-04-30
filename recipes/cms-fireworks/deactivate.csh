#!/usr/bin/env csh

unsetenv ROOTSYS
unsetenv CMSSW_RELEASE_BASE
unsetenv CMSSW_BASE
if [[ "$(uname)" == "Linux" ]]; then
  setenv LD_LIBRARY_PATH ${OLD_LD_LIBRARY_PATH}
  unsetenv OLD_LD_LIBRARY_PATH
else
  setenv DYLD_FALLBACK_LIBRARY_PATH ${OLD_DYLD_FALLBACK_LIBRARY_PATH}
  unsetenv OLD_DYLD_FALLBACK_LIBRARY_PATH
fi
unsetenv LIBRARY_PATH
unsetenv ROOT_INCLUDE_PATH
unsetenv CMSSW_SEARCH_PATH
unsetenv CMSSW_DATA_PATH
unsetenv CMSSW_RELEASE
unalias cmsShow
