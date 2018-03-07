#!/bin/bash
$PYTHON configure.py
$PYTHON setup.py install --single-version-externally-managed --record record.txt && cd test && python -m pytest
