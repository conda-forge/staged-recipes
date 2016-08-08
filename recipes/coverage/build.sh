#!/bin/bash


$PYTHON setup.py install --single-version-externally-managed --record record.txt

# Remove versioned entrypoints.
PY_VER_MAJ=$($PYTHON -c "import os; print('_'.join(os.environ['PY_VER'].split('.')[0]))")

rm "${PREFIX}/bin/coverage${PY_VER_MAJ}"
rm "${PREFIX}/bin/coverage-${PY_VER}"

ls $PREFIX/bin/coverage*
