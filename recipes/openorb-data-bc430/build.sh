#!/bin/bash

# Get the BC430 ephemeris
getBC430

# Install
mkdir -p "$PREFIX/share/openorb"
cp -a asteroid_{indices,masses,ephemeris}.txt "$RECIPE_DIR/SHA256SUMS.bc430" "$PREFIX/share/openorb"
