#!/bin/bash

python setup.py install --single-version-externally-managed --record=record.txt

cp bdist_conda.py "${PREFIX}/lib/python${PY_VER}/distutils/command/"

rm -f "${PREFIX}/bin/conda"
