#!/usr/bin/env bash

# preserve the user's existing setting
if [ ! -z "${GO4SYS+x}" ]; then
	export CONDA_BACKUP_GO4SYS="${GO4SYS}"
fi
if [ ! -z "${ROOT_INCLUDE_PATH+x}" ]; then
	export CONDA_BACKUP_ROOT_INCLUDE_PATH="${ROOT_INCLUDE_PATH}"
fi

export GO4SYS="${CONDA_PREFIX}"
export PYTHONPATH=$GO4SYS/python:$PYTHONPATH
export ROOT_INCLUDE_PATH="${CONDA_PREFIX}/include":$ROOT_INCLUDE_PATH
