#!/bin/bash

if [[ `uname` == Darwin ]] && [ $PY_VER == "2.7" ]; then
    # tests fail on OSX for pyamg 3.0.2
    # This is currently an unresolved issue
    echo "skipping tests; see https://github.com/pyamg/pyamg/issues/165"
else
    nosetests -v pyamg
fi
