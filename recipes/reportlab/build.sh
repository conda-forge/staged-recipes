#!/bin/bash

$PYTHON setup.py install --single-version-externally-managed --record=record.txt

$PYTHON setup.py tests
