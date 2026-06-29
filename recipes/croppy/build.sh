#!/bin/bash
set -euxo pipefail

$PYTHON -m pip install . -vv --no-deps --no-build-isolation

# Install the menuinst shortcut spec and its icons into $PREFIX/Menu so the
# installer (conda / mamba / pixi global) creates a native desktop entry.
mkdir -p "$PREFIX/Menu"
cp "$RECIPE_DIR/menu/croppy.json" "$PREFIX/Menu/croppy.json"
cp "$RECIPE_DIR/icons/croppy.ico" "$PREFIX/Menu/croppy.ico"
cp "$RECIPE_DIR/icons/croppy.icns" "$PREFIX/Menu/croppy.icns"
cp "$RECIPE_DIR/icons/croppy.png" "$PREFIX/Menu/croppy.png"
