#!/bin/bash

set -e
#./sigprofiler -ig GRCh38
./sigprofiler -h
cp * ${PREFIX}/bin/
chmod u+rwx $PREFIX/bin/*
