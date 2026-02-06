#!/bin/bash
set -euxo pipefail

mkdir -p "${PREFIX}/bin"
cp scip "${PREFIX}/bin/scip"
chmod +x "${PREFIX}/bin/scip"

mkdir -p "${PREFIX}/share/doc/scip"
cp LICENSE "${PREFIX}/share/doc/scip/"
