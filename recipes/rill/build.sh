#!/bin/bash
set -exuo pipefail

pushd cli
go-licenses save . --save_path ../library_licenses --ignore modernc.org/mathutil --ignore go.uber.org/zap/exp/zapslog
popd

# Don't use bundled pre-built static libs
export GOFLAGS='-tags=duckdb_use_lib,dynamic'
make cli
mkdir -p $PREFIX/bin
mv rill $PREFIX/bin/

# Clear out cache to avoid file not removable warnings
chmod -R u+w $(go env GOPATH) && rm -r $(go env GOPATH)
