#!/usr/bin/env bash

set -euxo pipefail

# Python client
sed -i "s/version=\"0.0.0\"/version=\"${PKG_VERSION}\"/g" v4-proto-py/setup.py

make v4-proto-py-gen
