#!/bin/bash

if [[ "${PY_VER}" =~ 3 ]]
then
    2to3 -w -n setup.py
    2to3 -w -n bin/*
    2to3 -w -n pyscrap
fi

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
