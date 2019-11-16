#!/bin/bash

rm -f $CONDA_PREFIX/bin/omnisci_insert_sample_data || true
rm -f $CONDA_PREFIX/bin/startomnisci || true
rm -f $CONDA_PREFIX/bin/omnisci_initdb || true

export PATH=$CONDA_OMNISCIDB_BACKUP_PATH
unset CONDA_OMNISCIDB_BACKUP_PATH
