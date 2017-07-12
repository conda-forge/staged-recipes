#!/bin/bash
PBR_VERSION=${PKG_VERSION}
export PBR_VERSION
python setup.py install --single-version-externally-managed --record record.txt
