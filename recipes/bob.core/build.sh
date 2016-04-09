#!/usr/bin/env bash

if [[ `uname` == 'Darwin' ]]; then
	MACOSX_DEPLOYMENT_TARGET=10.7
	CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
	LINKFLAGS="${LINKFLAGS} -stdlib=libc++"
	$PYTHON -B setup.py install --single-version-externally-managed --record record.txt
else
	$PYTHON -B setup.py install --single-version-externally-managed --record record.txt
fi


