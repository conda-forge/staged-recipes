#!/bin/bash
set -euo pipefail

mkdir -p "${PREFIX}/lib/balena-cli"
cp -r ./* "${PREFIX}/lib/balena-cli/"

mkdir -p "${PREFIX}/bin"
ln -sf "${PREFIX}/lib/balena-cli/bin/balena" "${PREFIX}/bin/balena"
