#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/goreleaser -ldflags="-s -w -X main.Version=${PKG_VERSION}"
go-licenses save . --save_path=license-files --ignore github.com/mattn/go-localereader --ignore golang.org/x/sys/unix --ignore golang.org/x/crypto/blake2b --ignore golang.org/x/sys/cpu --ignore golang.org/x/crypto/blake2s --ignore golang.org/x/crypto/sha3 --ignore github.com/cloudflare/circl/dh/x25519 --ignore github.com/ipfs/bbloom --ignore golang.org/x/crypto/salsa20/salsa --ignore github.com/multiformats/go-base36
