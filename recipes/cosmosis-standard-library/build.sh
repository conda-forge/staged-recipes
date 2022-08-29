#!/usr/bin/env bash


mkdir -p "${PREFIX}/lib/cosmosis-standard-library"
cp -a -r * "${PREFIX}/lib/cosmosis-standard-library"
cd "${PREFIX}/lib/cosmosis-standard-library"

make


