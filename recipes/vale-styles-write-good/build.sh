#!/usr/bin/env bash
set -eux
export STYLES="${PREFIX}/share/vale/styles"
mkdir -p "${STYLES}"
cp -r "write-good/"  "${STYLES}/"