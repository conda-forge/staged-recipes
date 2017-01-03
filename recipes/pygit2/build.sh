#!/bin/bash

export LIBGIT2=${PREFIX}

$PYTHON setup.py install --single-version-externally-managed --record record.txt
