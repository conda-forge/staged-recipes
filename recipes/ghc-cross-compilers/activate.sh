#!/bin/bash

if [[ "$(uname)" == "Linux" ]] && [[ "$(uname -m)" == "x86_64" ]]; then
  aarch64-conda-linux-gnu-ghc-pkg recache
fi
