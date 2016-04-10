#!/usr/bin/env bash

if [[ `uname` == 'Darwin' ]]; then
	CFLAGS="${CFLAGS} -DBOOST_NO_CXX11_RVALUE_REFERENCES"
	CXXFLAGS="${CXXFLAGS} -DBOOST_NO_CXX11_RVALUE_REFERENCES"
	LDFLAGS="${LDFLAGS} -DBOOST_NO_CXX11_RVALUE_REFERENCES"
	$PYTHON -B setup.py install --single-version-externally-managed --record record.txt
else
	$PYTHON -B setup.py install --single-version-externally-managed --record record.txt
fi
