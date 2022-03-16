#!/bin/bash

cp numberofcharacters.h src/pdftopng/

$PYTHON setup.py build

$PYTHON -m pip install . -vv

