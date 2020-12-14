#!/usr/bin/env fish

# env vars expected by cmsShow
set -gx CMSSW_RELEASE_BASE ""
set -gx CMSSW_BASE "$CONDA_PREFIX"
set -gx CMSSW_SEARCH_PATH "$CONDA_PREFIX/data"
set -gx CMSSW_DATA_PATH "$CONDA_PREFIX/data"
set -gx CMSSW_VERSION CMSSW_XX_YY_ZZ

switch (uname)
    case Darwin
        if set -q DYLD_FALLBACK_LIBRARY_PATH
            set -gx DYLD_FALLBACK_LIBRARY_PATH "$CONDA_PREFIX/lib:$DYLD_FALLBACK_LIBRARY_PATH"
        else
            set -gx DYLD_FALLBACK_LIBRARY_PATH "$CONDA_PREFIX/lib"
        end
    case Linux
        if set -q LD_LIBRARY_PATH
            set -gx LD_LIBRARY_PATH "$CONDA_PREFIX/lib:$LD_LIBRARY_PATH"
        else
            set -gx LD_LIBRARY_PATH "$CONDA_PREFIX/lib"
        end
end

if set -q ROOT_INCLUDE_PATH
    set -gx ROOT_INCLUDE_PATH "$CONDA_PREFIX/src:$ROOT_INCLUDE_PATH"
else
    set -gx ROOT_INCLUDE_PATH "$CONDA_PREFIX/src"
end
