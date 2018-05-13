#!/bin/bash
set -eu -o pipefail

./bootstrap-ldc.sh

cp -a * $PREFIX
