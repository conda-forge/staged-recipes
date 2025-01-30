#!/usr/bin/env bash

export _RENODE_CORES_PATH_BACKUP=${RENODE_CORES_PATH:-}
export RENODE_CORES_PATH=${CONDA_PREFIX}/lib/renode-cores
