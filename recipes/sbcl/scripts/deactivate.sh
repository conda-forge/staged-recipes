#!/bin/bash

# Restore previous env vars if they were set.
unset SBCL_HOME
if [[ -n "$_SBCL_HOME_CONDA_BACKUP" ]]; then
    export SBCL_HOME=$_SBCL_HOME_CONDA_BACKUP
    unset _SBCL_HOME_CONDA_BACKUP
fi