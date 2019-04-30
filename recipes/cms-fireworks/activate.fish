#!/usr/bin/env fish

set -gx ROOTSYS "$CONDA_PREFIX"
# env vars expected by cmsShow
set -gx CMSSW_RELEASE_BASE ""
set -gx CMSSW_BASE "${CONDA_PREFIX}"
set -gx CMSSW_SEARCH_PATH "${CONDA_PREFIX}/data"
set -gx CMSSW_DATA_PATH "${CONDA_PREFIX}/data"
set -gx CMSSW_VERSION CMSSW_10_5_0
# Only on macOS
switch (uname)
    # Only if not in the base env (let's be nice)
    case Darwin
        if [ "$CONDA_DEFAULT_ENV" != "base" ]
            if not set -q CONDA_BUILD_SYSROOT
                echo "WARNING: Compiling likely won't work unless you download the macOS 10.9 SDK and set CONDA_BUILD_SYSROOT."
                echo "You can probably ignore this warning and just omit + or ++ when executing ROOT macros."
            end
        end
        set -gx OLD_DYLD_FALLBACK_LIBRARY_PATH ${DYLD_FALLBACK_LIBRARY_PATH}
        set -gx DYLD_FALLBACK_LIBRARY_PATH "${CONDA_PREFIX}/lib:$DYLD_FALLBACK_LIBRARY_PATH"
        set -gx ROOT_INCLUDE_PATH "${CONDA_PREFIX}/src:${CONDA_PREFIX}/include:${CONDA_BUILD_SYSROOT}/usr/include"
    case Linux
        set -gx OLD_LD_LIBRARY_PATH ${LD_LIBRARY_PATH}
        set -gx LD_LIBRARY_PATH "${CONDA_PREFIX}/lib:${LD_LIBRARY_PATH}"
        set -gx ROOT_INCLUDE_PATH "${CONDA_PREFIX}/src:${CONDA_PREFIX}/include"
end
alias cmsShow 'cmsShow.exe'

if not test -e ${CONDA_PREFIX}/.pch-regenerated
  cd ${CONDA_PREFIX}
  echo 'Regenerating ${CONDA_PREFIX}/etc/allDict.cxx.pch on first activation.'
  begin
     set -lx ROOTIGNOREPREFIX 1
     python etc/dictpch/makepch.py etc/allDict.cxx.pch -I./include
  end
  echo 'Done'
  date >.pch-regenerated
  cd - 2>/dev/null
end
