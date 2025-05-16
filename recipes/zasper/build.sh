#!/bin/bash
set -eoux pipefail

make init
make build

# Ensure the binary exists
test -f zasper

# Install the binary into Conda env bin/
install -m755 zasper "$PREFIX/bin/zasper"
