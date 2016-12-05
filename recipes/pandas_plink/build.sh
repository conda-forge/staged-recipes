#!/bin/bash

brew install libffi

python setup.py install --single-version-externally-managed --record record.txt
