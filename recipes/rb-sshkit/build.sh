#!/bin/bash
set -euo pipefail
GEM_NAME="${PKG_NAME#rb-}"
gem install --norc -l -V --ignore-dependencies "${GEM_NAME}-${PKG_VERSION}.gem"
gem unpack "${GEM_NAME}-${PKG_VERSION}.gem"
