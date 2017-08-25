#!/bin/bash

# Restore previous env vars if they were set.
unset JCC_JDK
if [[ -n "$_JCC_JDK_CONDA_BACKUP" ]]; then
    export JCC_JDK=$_JCC_JDK_CONDA_BACKUP
    unset _JCC_JDK_CONDA_BACKUP
fi
