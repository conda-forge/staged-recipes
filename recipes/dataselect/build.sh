#!/bin/bash
set -euxo pipefail

make

mkdir -p "${PREFIX}/bin" "${PREFIX}/share/man/man1"
install -m 755 dataselect "${PREFIX}/bin/dataselect"
install -m 644 doc/dataselect.1 "${PREFIX}/share/man/man1/dataselect.1"
