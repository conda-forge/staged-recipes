#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -o="${PREFIX}/bin/brief" -ldflags="-s -w -X github.com/git-pkgs/brief.Version=${PKG_VERSION}" ./cmd/brief

# oapi-codegen/nullable's LICENSE file only contains the Apache-2.0 notice
# boilerplate (not the full license text), so go-licenses can't classify it.
# Ignore it in the scan and copy its real license in manually.
go-licenses save ./cmd/brief --save_path=license-files --ignore github.com/oapi-codegen/nullable
mkdir -p license-files/github.com/oapi-codegen/nullable
cp "$(go list -m -f '{{ .Dir }}' github.com/oapi-codegen/nullable)/LICENSE" license-files/github.com/oapi-codegen/nullable/LICENSE

# allow conda to clean up the read-only go module cache
chmod -R u+w "$(go env GOPATH)"
