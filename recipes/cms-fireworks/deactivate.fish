#!/usr/bin/env fish

set -e ROOTSYS

set -e CMSSW_RELEASE_BASE
set -e CMSSW_BASE
switch (uname)
  case Darwin
    set -gx DYLD_FALLBACK_LIBRARY_PATH ${OLD_DYLD_FALLBACK_LIBRARY_PATH}
    set -e OLD_DYLD_FALLBACK_LIBRARY_PATH
  case Linux
    set -gx LD_LIBRARY_PATH ${OLD_LD_LIBRARY_PATH}
    set -e OLD_LD_LIBRARY_PATH
end
set -e LIBRARY_PATH
set -e ROOT_INCLUDE_PATH
set -e CMSSW_SEARCH_PATH
set -e CMSSW_DATA_PATH
unalias cmsShow
