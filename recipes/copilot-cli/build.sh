#!/bin/bash
set -euxo pipefail


ls -la

chmod +x ./copilot

mkdir -p "${PREFIX}/bin"
cp ./copilot "${PREFIX}/bin/copilot"

check-glibc "${PREFIX}"/bin/*
