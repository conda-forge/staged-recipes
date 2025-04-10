#!/usr/bin/bash

set -evx
export CONDA_BUILD=""
conda build --no-anaconda-upload --keep-old-work test
conda build --no-anaconda-upload --keep-old-work examples/gmp
conda build --no-anaconda-upload --keep-old-work examples/emacs
