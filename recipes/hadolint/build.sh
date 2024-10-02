#!/usr/bin/env bash

set -o xtrace -o pipefail -o errexit

mkdir -p "$PREFIX/bin"

if [[ $target_platform =~ linux.* ]]; then
  install hadolint-Linux-x86_64 "$PREFIX/bin/hadolint"
else
  install hadolint-Darwin-x86_64 "$PREFIX/bin/hadolint"
fi
