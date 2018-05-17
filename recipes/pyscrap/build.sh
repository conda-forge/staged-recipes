#!/bin/bash

if [[ "${PY_VER}" =~ 3 ]]
then
    2to3 -w -n setup.py
    2to3 -w -n bin/*
    2to3 -w -n pyscrap/*
fi

$PYTHON -m pip install --no-deps --ignore-installed .
