#!/usr/bin/env bash

set -exuo pipefail

# go run xcaddy/cmd/xcaddy/main.go build v2.6.4 --output "$PREFIX/bin/caddy"

# export GOPATH="$( pwd )"
go build -v -o "$PREFIX/bin/caddy"

# go-licenses save . --save_path=./license-files
