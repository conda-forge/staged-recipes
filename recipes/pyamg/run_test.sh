#!/bin/bash

if [[ `uname` == Darwin ]] && [ $PY_VER == "2.7" ]; then
    echo "skipping tests; see https://github.com/pyamg/pyamg/issues/165"
else
    nosetests -v pyamg
fi
