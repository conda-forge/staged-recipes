#!/bin/bash

pushd build
  make install ${VERBOSE_CM}
popd
[[ -d "${PREFIX}"/share/LIEF/examples ]] && rm -rf "${PREFIX}"/share/LIEF/examples/
