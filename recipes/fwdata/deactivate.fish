#!/usr/bin/env fish

set -e CMSSW_RELEASE_BASE
set -e CMSSW_BASE
set -e CMSSW_SEARCH_PATH
set -e CMSSW_DATA_PATH
set -e CMSSW_RELEASE

switch (uname)
  case Darwin
    set -e DYLD_FALLBACK_LIBRARY_PATH
  case Linux
    set -e LD_LIBRARY_PATH
end
set -e ROOT_INCLUDE_PATH
