#!/bin/bash

"${PYTHON}" setup.py configure --hdf5="${PREFIX}"
"${PYTHON}" setup.py install --single-version-externally-managed --record record.txt
