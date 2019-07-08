#!/bin/bash

set -x -e

if [ "$(uname)" = "Linux" ] ; then
	SED='sed -i' ;
else 
	SED='sed -i '"'"''"'"' ' ;
fi

export CC=`which h5c++`

pushd sucpp; make clean; make test; make main; make api; popd
pushd sucpp; ./test_su; ./test_api; popd

$PYTHON -m pip install . --no-deps -vv
