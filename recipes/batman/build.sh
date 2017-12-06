#!/bin/bash

"${PYTHON}" setup.py build_fortran

"${PYTHON}" setup.py install --single-version-externally-managed --record record.txt
