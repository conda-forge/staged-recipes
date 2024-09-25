#!/bin/bash

set -euxo pipefail

cmake --install ./sdk/build --prefix=${PREFIX}
