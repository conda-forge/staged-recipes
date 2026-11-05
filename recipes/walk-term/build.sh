#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Remove any pre-existing license-files directory to avoid conflicts.
rm -rf license-files

# Save licenses of dependencies, ignoring specified packages
go-licenses save . --save_path=license-files --ignore github.com/mattn/go-localereader

# Manually add the missing license in the expected directory structure
mkdir -p ${RECIPE_DIR}/license-files/github.com/mattn/go-localereader
curl -L https://raw.githubusercontent.com/mattn/go-localereader/master/LICENSE \
  -o ${RECIPE_DIR}/license-files/github.com/mattn/go-localereader/LICENSE

# Merge manual licenses into the saved license directory
cp -r ${RECIPE_DIR}/license-files/* license-files/

# Build the Go binary for 'walk'; GOFLAGS already injects necessary flags
go build -o="${PREFIX}/bin/walk" -ldflags="-s -w -X main.Version=${PKG_VERSION}"
