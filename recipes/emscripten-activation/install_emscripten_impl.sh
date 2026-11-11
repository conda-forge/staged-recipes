#!/bin/bash
set -ex

pushd "${PREFIX}"/bin
  for BINARY in "em++" "em-config" "emar" "embuilder" "emcc" "emcmake" "emconfigure" "emmake" "emranlib" "emrun" "emscons" "emsize" "emstrip" "emsymbolizer"; do
    ln -s $BINARY ${CHOST}-$BINARY
    if [[ "${CBUILD}" != ${CHOST} ]]; then
      ln -s $BINARY ${CBUILD}-$BINARY
    fi
  done
popd
