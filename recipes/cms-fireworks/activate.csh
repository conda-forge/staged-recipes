#!/usr/bin/env csh

# env vars expected by cmsShow
setenv CMSSW_RELEASE_BASE ""
setenv CMSSW_BASE "${CONDA_PREFIX}"
setenv CMSSW_SEARCH_PATH "${CONDA_PREFIX}/data"
setenv CMSSW_DATA_PATH "${CONDA_PREFIX}/data"
setenv CMSSW_VERSION CMSSW_XX_YY_ZZ

if [[ "$(uname)" == "Darwin" ]]; then
    if (! $?DYLD_FALLBACK_LIBRARY_PATH) then
        setenv DYLD_FALLBACK_LIBRARY_PATH "${CONDA_PREFIX}/lib:${DYLD_FALLBACK_LIBRARY_PATH}"
    else
        if ("$DYLD_FALLBACK_LIBRARY_PATH" == "")  then
            setenv DYLD_FALLBACK_LIBRARY_PATH "${CONDA_PREFIX}/lib:${DYLD_FALLBACK_LIBRARY_PATH}"
        else
            setenv DYLD_FALLBACK_LIBRARY_PATH "${CONDA_PREFIX}/lib:${DYLD_FALLBACK_LIBRARY_PATH}:${DYLD_FALLBACK_LIBRARY_PATH}"
        endif
    endif
else
    if (! $?LD_LIBRARY_PATH) then
        setenv LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:${CONDA_PREFIX}/lib"
    else
        if ("$LD_LIBRARY_PATH" == "")  then
            setenv LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:${CONDA_PREFIX}/lib"
        else
            setenv LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:${CONDA_PREFIX}/lib:${LD_LIBRARY_PATH}"
        endif
    endif
fi

if (! $?ROOT_INCLUDE_PATH) then
    setenv ROOT_INCLUDE_PATH "${CONDA_PREFIX}/src"
else
    if ("$ROOT_INCLUDE_PATH" == "")  then
        setenv ROOT_INCLUDE_PATH "${CONDA_PREFIX}/src"
    else
        setenv ROOT_INCLUDE_PATH "${CONDA_PREFIX}/src:${ROOT_INCLUDE_PATH}"
    endif
endif
