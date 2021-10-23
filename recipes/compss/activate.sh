#!/usr/bin/env bash
  
export PYTHIA8="${CONDA_PREFIX}"
export PATH=$PATH:${CONDA_PREFIX}/lib/python3.7/site-packages/pycompss/COMPSs/Runtime/scripts/user:${CONDA_PREFIX}/lib/python3.7/site-packages/pycompss/COMPSs/Runtime/scripts/utils:${CONDA_PREFIX}/lib/python3.7/site-packages/pycompss/COMPSs/Bindings/c/bin:$PATH
export CLASSPATH=$CLASSPATH:${CONDA_PREFIX}/lib/python3.7/site-packages/pycompss/COMPSs/Runtime/compss-engine.jar
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${CONDA_PREFIX}//lib/python3.7/site-packages/pycompss/COMPSs/Bindings/bindings-common/lib:${CONDA_PREFIX}/jre/lib/amd64/server
export PYTHONPATH=$PYTHONPATH:${CONDA_PREFIX}//lib/python3.7/site-packages/pycompss/COMPSs/Bindings/python/3:${CONDA_PREFIX}//lib/python3.7/site-packages/pycompss/COMPSs/Bindings/python/3/pycompss/api
