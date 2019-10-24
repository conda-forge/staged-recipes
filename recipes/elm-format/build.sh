#!/usr/bin/env bash
set -ex

if [ "$(uname)" == "Darwin" ]; then
  # On Mac, we can use pre-built binaries
  mkdir -p "${PREFIX}/bin"
  cp elm-format "${PREFIX}/bin/elm-format"
else
  # on linux, we have to build from source to avoid older version of GLIBC
  stack setup
  stack install shake
  stack runhaskell Shakefile.hs -- build
  mkdir -p "${PREFIX}/bin"
  cp "$(stack path --local-install-root)"/bin/elm-format "${PREFIX}/bin/elm-format"
fi