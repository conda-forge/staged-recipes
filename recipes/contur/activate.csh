#!/usr/bin/env csh

setenv CONTUR_ROOT "${CONDA_PREFIX}"
setenv CONTUR_DATA_PATH "${CONDA_PREFIX}/share/contur"
setenv CONTUR_USER_DIR "${CONDA_PREFIX}/contur_users"

# if CONTUR_USER_DIR does not exist create it
if ( ! -d "${CONTUR_USER_DIR}" ) then
    mkdir -p "${CONTUR_USER_DIR}"
endif

# preserve the existing settings
if ( $?RIVET_DATA_PATH ) then
    setenv _CONDA_BACKUP_RIVET_DATA_PATH "${RIVET_DATA_PATH}"
endif
if ( $?RIVET_ANALYSIS_PATH ) then
    setenv _CONDA_BACKUP_RIVET_ANALYSIS_PATH "${RIVET_ANALYSIS_PATH}"
endif
setenv RIVET_DATA_PATH "${CONTUR_DATA_PATH}/data/Rivet:${CONTUR_DATA_PATH}/data/Theory:${RIVET_DATA_PATH}"
setenv RIVET_ANALYSIS_PATH "${CONTUR_DATA_PATH}/data/Rivet:${CONTUR_USER_DIR}:${RIVET_ANALYSIS_PATH}"


if ( ! -f "${CONTUR_USER_DIR}/analysis-list" ) then
    set _return_path=`pwd -P`
    cd "${CONTUR_DATA_PATH}"
    make
    cd "${_return_path}"
    unset _return_path
endif
if ( -f "${CONTUR_USER_DIR}/analysis-list" ) then
    source "${CONTUR_USER_DIR}/analysis-list"
endif
