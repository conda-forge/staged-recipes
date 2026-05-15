#!/bin/bash
set -euo pipefail

mkdir -p "${PREFIX}/lib/balena-cli"
cp -r balena-cli/* "${PREFIX}/lib/balena-cli/"

mkdir -p "${PREFIX}/bin"
ln -sf "${PREFIX}/lib/balena-cli/balena" "${PREFIX}/bin/balena"
