#!/usr/bin/env bash

if [[ `uname` == 'Darwin' ]]; then
	MACOSX_VERSION_MIN=10.7
	CXXFLAGS="-mmacosx-version-min=${MACOSX_VERSION_MIN}"
	CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
	LINKFLAGS="-mmacosx-version-min=${MACOSX_VERSION_MIN}"
	LINKFLAGS="${LINKFLAGS} -stdlib=libc++"
	CMAKE_OSX_DEPLOYMENT_TARGET="${MACOSX_VERSION_MIN}"
	$PYTHON -B setup.py install --single-version-externally-managed --record record.txt
else
	$PYTHON -B setup.py install --single-version-externally-managed --record record.txt
fi


