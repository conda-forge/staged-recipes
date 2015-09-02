#!/usr/bin/env bash

mkdir -p $PREFIX/share
$PYTHON -c "Testing an example package." > $PREFIX/share/example.txt
