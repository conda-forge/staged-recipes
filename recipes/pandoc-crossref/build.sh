#!/bin/bash

mkdir -p "$PREFIX/bin"
/bin/mv pandoc-crossref "$PREFIX/bin"
if [[ "$(uname)" == Darwin ]]; then
  /bin/mv pandoc-crossref.1 "$PREFIX/bin"
fi
