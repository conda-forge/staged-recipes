#!/bin/bash

CFLAGS="-I${PREFIX}/include ${CFLAGS}" "${PYTHON}" setup.py install --single-version-externally-managed --record=record.txt
