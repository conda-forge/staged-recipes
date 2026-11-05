#!/usr/bin/env bash
set -euo pipefail

# SRProxy is not compiled here: it ships headers (incl. BasicTypesProxy.cxx, which
# downstream consumers compile) and a Python generator script.
mkdir -p "${PREFIX}/include/SRProxy" "${PREFIX}/bin"
cp BasicTypesProxy.h BasicTypesProxy.cxx FlatBasicTypes.h IBranchPolicy.h "${PREFIX}/include/SRProxy/"
install -m 0755 gen_srproxy "${PREFIX}/bin/gen_srproxy"
