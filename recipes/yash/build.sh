#!/bin/bash

set -exo pipefail

export XML_CATALOG_FILES="${PREFIX}/etc/xml/catalog"

./configure --prefix="${PREFIX}"

find / -name manpage.xsl

make "-j${CPU_COUNT}"
make install
