#!/bin/bash

set -e
#./sigprofiler -ig GRCh38
./sigprofiler -h
cp -r * ${PREFIX}/bin/
chmod u+rwx $PREFIX/bin/*
