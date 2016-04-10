#!/usr/bin/env bash

if [[ `uname` == 'Darwin' ]]; then
	CXXFLAGS="${CXXFLAGS} -DBOOST_NO_CXX11_RVALUE_REFERENCES"
	$PYTHON -B setup.py install --single-version-externally-managed --record record.txt
else
	$PYTHON -B setup.py install --single-version-externally-managed --record record.txt
fi
