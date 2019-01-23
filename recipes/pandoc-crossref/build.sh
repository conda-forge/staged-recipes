#!/bin/bash

mkdir -p "$PREFIX/bin"
/bin/mv pandoc-crossref "$PREFIX/bin"
if [[ -f pandoc-crossref.1 ]]; then
  /bin/mv pandoc-crossref.1 "$PREFIX/bin"
fi
