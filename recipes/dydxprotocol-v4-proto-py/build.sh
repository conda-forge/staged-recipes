#!/usr/bin/env bash

set -euxo pipefail

# Python client
if [[ "$(uname)" == "Darwin" ]]; then
  sed -i '' "s/version=\"0.0.0\"/version=\"${PKG_VERSION}\"/g" v4-proto-py/setup.py
else
  sed -i "s/version=\"0.0.0\"/version=\"${PKG_VERSION}\"/g" v4-proto-py/setup.py
fi

make v4-proto-py-gen
