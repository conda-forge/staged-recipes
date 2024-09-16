#!/bin/bash

set -exo pipefail

export XML_CATALOG_FILES="${PREFIX}/etc/xml/catalog"

./configure --prefix="${PREFIX}"

make "-j${CPU_COUNT}"
make install
