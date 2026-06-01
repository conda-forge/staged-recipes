#!/bin/bash

set -ex

mkdir -p "${PREFIX}"
mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/lib"
mkdir -p "${PREFIX}/lib-src"
mkdir -p "${PREFIX}/bat"

find . -type f 1>&2

cp -v log4j2.properties LICENSE NOTICE "${PREFIX}/"
cp -vr bin/ "${PREFIX}/bin"
cp -vr lib/ "${PREFIX}/lib"
cp -vr lib/ "${PREFIX}/lib-src"
cp -vr bat/ "${PREFIX}/bat"


chmod +x ${PREFIX}/bin/*

