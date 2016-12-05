#!/bin/bash

conda install libffi -y

python setup.py install --single-version-externally-managed --record record.txt
