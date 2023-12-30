#!/bin/bash

set -exuo pipefail

## remove copilot
rm -rf marimo/_lsp
sed -i '/_lsp/d' MANIFEST.in marimo.egg-info/SOURCES.txt
