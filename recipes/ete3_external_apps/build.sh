#!/bin/bash

$PYTHON compile_all.py
cp -r bin/ $PREFIX/bin/ete3_apps/
echo %VERSION% > $PREFIX/bin/ete3_apps/__version__
