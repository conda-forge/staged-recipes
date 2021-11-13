#!/bin/bash

# Unset environment variable that was set upon environment activation.
if [ -z $PMIP_CBC_LIBRARY_BACKUP ]; then
    export PMIP_CBC_LIBRARY=$CONDA_BACKUP_PMIP_CBC_LIBRARY
    unset CONDA_BACKUP_PMIP_CBC_LIBRARY
else
    unset PMIP_CBC_LIBRARY
fi
