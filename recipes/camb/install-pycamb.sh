#!/bin/bash

cd pycamb
${PYTHON} setup.py install --single-version-externally-managed --record record.txt --skip-build

#-m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
