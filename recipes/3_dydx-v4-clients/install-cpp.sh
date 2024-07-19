#!/usr/bin/env bash

set -euxo pipefail

cd v4-client-cpp/build
  make install
cd ../..
