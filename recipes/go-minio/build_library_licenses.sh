#!/usr/bin/env bash
set -eux

export LIBRARY_LICENSES_PATH="$SRC_DIR/library_licenses/"

go-licenses save \
    "." \
    --save_path "$LIBRARY_LICENSES_PATH" \
    2>&1 \
    | tee "$SRC_DIR/go-licenses.log" \
    || echo "ignoring errors until go-licenses --ignore is available"

find "$LIBRARY_LICENSES_PATH"
