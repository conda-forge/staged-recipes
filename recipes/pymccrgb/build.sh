#!/bin/bash

python setup.py --quiet install --single-version-externally-managed --record=record.txt
pip install git+https://github.com/stgl/pymcc 
