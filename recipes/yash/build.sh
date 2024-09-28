#!/bin/bash

set -exuo pipefail

export XML_CATALOG_FILES=${PREFIX}/etc/asciidoc/docbook-xsl/manpage.xsl
./configure --prefix="${PREFIX}"
make install "-j${CPU_COUNT}"
