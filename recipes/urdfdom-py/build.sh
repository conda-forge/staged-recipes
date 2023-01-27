#!/bin/sh

$PYTHON setup.py install --prefix=$PREFIX --install-lib=$SP_DIR --single-version-externally-managed --record ./installed_files
