#!/bin/bash

set -exuo pipefail

mkdir -p $PREFIX/bin
cp build/dist/bin/duckdb $PREFIX/bin/

