#!/usr/bin/env bash

mkdir -p $PREFIX/share
$PYTHON -c "print('Testing an example package.')" > $PREFIX/share/example.txt
