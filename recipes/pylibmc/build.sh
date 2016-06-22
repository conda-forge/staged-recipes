#!/bin/bash
source activate "${CONDA_DEFAULT_ENV}"

"${PYTHON}" setup.py install --with-libmemcached="${PREFIX}"
