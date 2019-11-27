#!/usr/bin/env bash

export PYTHIA8="${CONDA_PREFIX}"
export PATH=$PATH:${CONDA_PREFIX}/COMPSs/Runtime/scripts/user:${CONDA_PREFIX}/COMPSs/Runtime/scripts/utils
export CLASSPATH=$CLASSPATH:${CONDA_PREFIX}/COMPSs/Runtime/compss-engine.jar
export PATH=$PATH:${CONDA_PREFIX}/COMPSs/Bindings/c/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${CONDA_PREFIX}/COMPSs/Bindings/bindings-common/lib:$JAVA_HOME/jre/lib/amd64/server

