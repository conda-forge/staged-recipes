#!/bin/bash

$PYTHON setup.py install --single-version-externally-managed --record record.txt

# delete the Psyplot.app. This should not be included in the conda-forge package
rm -rf psyplot_gui/app/Psyplot.app

