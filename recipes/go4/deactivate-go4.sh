#!/usr/bin/env bash

# reinstate the backup from outside the environment
if [ ! -z "${CONDA_BACKUP_GO4SYS}" ]; then
	export GO4SYS="${CONDA_BACKUP_GO4SYS}"
	unset CONDA_BACKUP_GO4SYS
# no backup, just unset
else
	unset GO4SYS
fi
if [ ! -z "${CONDA_BACKUP_ROOT_INCLUDE_PATH}" ]; then
	export ROOT_INCLUDE_PATH="${CONDA_BACKUP_ROOT_INCLUDE_PATH}"
	unset CONDA_BACKUP_ROOT_INCLUDE_PATH
# no backup, just unset
else
	unset ROOT_INCLUDE_PATH
fi
