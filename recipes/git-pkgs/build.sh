#!/usr/bin/env bash
set -euxo pipefail

go build -trimpath -buildmode=pie \
    -ldflags="-s -w -X github.com/git-pkgs/git-pkgs/cmd.version=${PKG_VERSION}" \
    -o "${PREFIX}/bin/git-pkgs" .

# Man pages
go run scripts/generate-man/main.go
mkdir -p "${PREFIX}/share/man/man1"
cp man/*.1 "${PREFIX}/share/man/man1/"

# oapi-codegen/nullable is Apache-2.0, but go-licenses cannot classify its short-form
# LICENSE notice, so it is ignored here and its LICENSE is copied in by hand.
# https://github.com/oapi-codegen/nullable?tab=License-1-ov-file
go-licenses save . --save_path=library_licenses \
    --ignore=github.com/oapi-codegen/nullable
mkdir -p library_licenses/github.com/oapi-codegen/nullable
cp "$(go list -m -f '{{.Dir}}' github.com/oapi-codegen/nullable)/LICENSE" \
    library_licenses/github.com/oapi-codegen/nullable/
