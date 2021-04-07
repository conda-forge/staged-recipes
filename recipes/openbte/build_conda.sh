#!/bin/bash

conda config --set anaconda_upload no
conda build --python=3.7 -c conda-forge  meta.yaml
conda build purge
