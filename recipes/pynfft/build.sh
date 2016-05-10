#!/bin/bash

# have to include the path to nfft.h
echo "[build_ext]" > setup.cfg
echo "include-dirs=$PREFIX/include/" >> setup.cfg

python setup.py install --single-version-externally-managed --record record.txt
