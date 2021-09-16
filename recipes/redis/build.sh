#!/bin/bash

make BUILD_TLS=yes
make PREFIX=$PREFIX install

if [[ "$target_platform" == osx* ]]; then
  make test
fi