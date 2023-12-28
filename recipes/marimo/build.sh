#!/bin/bash

## remove copilot
rm -rf marimo/_lsp
sed -i '/_lsp/d' MANIFEST.in marimo.egg-info/SOURCES.txt

## build
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
