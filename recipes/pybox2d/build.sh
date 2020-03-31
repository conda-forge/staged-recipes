#!/bin/bash

$PYTHON setup.py build --force
$PYTHON -m pip install . -vv
