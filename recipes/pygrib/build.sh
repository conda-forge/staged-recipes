#!/bin/bash

export GRIBAPI_DIR=$PREFIX
export JASPER_DIR=$PREFIX
export PNG_DIR=$PREFIX
$PYTHON setup.py install
