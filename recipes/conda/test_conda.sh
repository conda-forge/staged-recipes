#!/bin/bash

# Check where we are.
echo $CONDA_PREFIX

# Check version via import.
python -c "from __future__ import print_function; import conda; print(conda.__version__)"

# Show where the conda commands are.
which conda
which conda-env

# Run some conda commands.
conda --version
conda info
conda env --help
