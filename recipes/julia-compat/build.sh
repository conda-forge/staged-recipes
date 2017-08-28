#!/bin/bash

JULIA_VERSION=0.5
JULIA_PKG_NAME=Compat

DEST="$PREFIX/share/julia/site/v$JULIA_VERSION/$JULIA_PKG_NAME"

mkdir -p "$DEST"
cp --recursive --archive --no-target-directory "$PWD" "$DEST"

