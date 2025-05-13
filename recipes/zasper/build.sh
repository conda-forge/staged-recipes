#!/bin/bash
set -ex

cd "$SRC_DIR"

BINARY="zasper"

chmod +x "$SRC_DIR/$BINARY"
mkdir -p "${PREFIX}/bin"
cp "$SRC_DIR/$BINARY" "${PREFIX}/bin/zasper"
