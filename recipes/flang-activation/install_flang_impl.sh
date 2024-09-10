#!/bin/bash
set -ex

pushd "${PREFIX}"/bin
  ln -s flang-new ${CHOST}-flang
  if [[ "${CBUILD}" != ${CHOST} ]]; then
    ln -s flang-new ${CBUILD}-flang
  fi
popd
