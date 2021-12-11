#!/bin/bash

python3 -m pip install src/ -vv

mkdir -p ${PREFIX}/bin

cp src/eodie_process.py ${PREFIX}/bin/eodie_process.py
