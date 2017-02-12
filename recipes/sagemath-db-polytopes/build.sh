#!/bin/bash

POLYTOPES_DIR="$PREFIX/share/reflexive_polytopes"
mkdir -p "$POLYTOPES_DIR"
cp -r -p *  "$POLYTOPES_DIR"
rm "$POLYTOPES_DIR/conda_build.sh"
