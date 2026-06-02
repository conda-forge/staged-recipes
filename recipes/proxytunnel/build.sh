#!/bin/bash

set -euxo pipefail

make

# Upstream "make install" also builds the man page with xmlto, which is not
# available on conda-forge.
install -d "${PREFIX}/bin"
install -p -m555 proxytunnel "${PREFIX}/bin/proxytunnel"
