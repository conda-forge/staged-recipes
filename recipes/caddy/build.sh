#!/usr/bin/env bash

set -exuo pipefail

# go run xcaddy/cmd/xcaddy/main.go build v2.6.4 --output "$PREFIX/bin/caddy"
go build -o "$PREFIX/bin/caddy"
