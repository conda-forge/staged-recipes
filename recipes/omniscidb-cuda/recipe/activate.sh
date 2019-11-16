#!/bin/bash

export CONDA_OMNISCIDB_BACKUP_PATH=$PATH
export PATH=$CONDA_PREFIX/opt/omnisci/bin:$PATH

ln -s $CONDA_PREFIX/opt/omnisci/bin/initdb $CONDA_PREFIX/bin/omnisci_initdb
ln -s $CONDA_PREFIX/opt/omnisci/startomnisci $CONDA_PREFIX/bin/startomnisci
ln -s $CONDA_PREFIX/opt/omnisci/insert_sample_data $CONDA_PREFIX/bin/omnisci_insert_sample_data
