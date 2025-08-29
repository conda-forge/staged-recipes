#!/bin/bash
set -ex

mkdir -p ${PREFIX}/include
cp -r include/* ${PREFIX}/include/
mkdir -p ${PREFIX}/share/cassini-headers
cp -r share/cassini-headers/* ${PREFIX}/share/cassini-headers/
