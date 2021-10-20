#!/usr/bin/env bash

cargo install --path . --bin qsv --root $PREFIX --features pcre2

# strip debug symbols
"$STRIP" "$PREFIX/bin/qsv"
