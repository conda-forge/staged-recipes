#!/bin/bash
"$PYTHON" setup.py version_module
"$PYTHON" setup.py install --single-version-externally-managed --record record.txt
