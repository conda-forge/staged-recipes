#!/bin/bash

ls -laF

$PYTHON $SRC_DIR/src/sas/qtgui/convertUI.py

python setup.py install --single-version-externally-managed --record=record.txt
