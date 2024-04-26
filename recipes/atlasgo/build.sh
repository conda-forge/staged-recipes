#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cd cmd/atlas

# NOTE: github.com/libsql/sqlite-antlr4-parser is generated and does not include a license.
#       Licenses for ANTLR4 projects are already included for other dependencies.
go-licenses save . \
    --save_path ../../library_licenses \
    --ignore ariga.io/atlas \
    --ignore github.com/libsql/sqlite-antlr4-parser

go build -v --ldflags '-s -w' -o $PREFIX/bin/atlas
