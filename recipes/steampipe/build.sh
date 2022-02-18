#!/bin/sh

export GOBIN="$PREFIX/bin"
go install -v .

# Complains about steampipe being AGPL-3.0
go-licenses save . --save_path=./license-files || true
test -d license-files/github.com
