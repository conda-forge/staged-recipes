#!/usr/bin/env bash

# Restore previous env vars if they were set.
unset RENODE_CORES_PATH
if [[ -n "$_RENODE_CORES_PATH_BACKUP" ]]; then
    export RENODE_CORES_PATH=$_RENODE_CORES_PATH_BACKUP
    unset _RENODE_CORES_PATH_BACKUP
fi