#!/usr/bin/env bash
set -euxo pipefail

mkdir -p "${PREFIX}/bin"
install -m 0755 k3d-* "${PREFIX}/bin/k3d"
