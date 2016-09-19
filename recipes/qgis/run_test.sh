#!/bin/bash

# Testing QGIS command currently is found as lint in meta.yaml
# QGIS has no --version, and --help exists 2
qgis --help || [[ "$?" == "2" ]]

# Check if we can import QGIS
# QGIS Python API isn't in default Python lib location
# Need to add location to PYTHONPATH
# Ref: http://docs.qgis.org/2.8/en/docs/pyqgis_developer_cookbook/intro.html?highlight=importerror#running-custom-applications

export PYTHONPATH=${PREFIX}/share/qgis/python:${PYTHONPATH}

python -c 'import qgis.core'
python -c 'import qgis.utils'

