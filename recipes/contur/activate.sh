#!/usr/bin/env bash

export CONTUR_ROOT="${CONDA_PREFIX}"
export CONTUR_DATA_PATH="${CONDA_PREFIX}/share/contur"
export CONTUR_USER_DIR="${CONDA_PREFIX}/contur_users"

# if CONTUR_USER_DIR does not exist create it
if [[ ! -d "${CONTUR_USER_DIR}" ]]; then
    mkdir -p "${CONTUR_USER_DIR}"
fi

# preserve the existing settings
if [[ -n "${RIVET_DATA_PATH+x}" ]]; then
    export _CONDA_BACKUP_RIVET_DATA_PATH="${RIVET_DATA_PATH}"
fi
if [[ -n "${RIVET_ANALYSIS_PATH+x}" ]]; then
    export _CONDA_BACKUP_RIVET_ANALYSIS_PATH="${RIVET_ANALYSIS_PATH}"
fi
export RIVET_DATA_PATH="${CONTUR_DATA_PATH}/data/Rivet:${CONTUR_DATA_PATH}/data/Theory:${RIVET_DATA_PATH}"
export RIVET_ANALYSIS_PATH="${CONTUR_DATA_PATH}/data/Rivet:${CONTUR_USER_DIR}:${RIVET_ANALYSIS_PATH}"


if [[ ! -f "${CONTUR_USER_DIR}/analysis-list" ]]; then
    _return_path="$(pwd -P)"
    cd "${CONTUR_DATA_PATH}"
    make
    cd "${_return_path}"
    unset _return_path
fi
if [[ -f "${CONTUR_USER_DIR}/analysis-list" ]]; then
    . "${CONTUR_USER_DIR}/analysis-list"
fi
