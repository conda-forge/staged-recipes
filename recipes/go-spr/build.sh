#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/amend -ldflags="-s -w" ./cmd/amend
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/reword -ldflags="-s -w" ./cmd/reword
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/spr -ldflags="-s -w" ./cmd/spr
go-licenses save ./cmd/amend --save_path=license-files_amend --ignore github.com/inigolabs/fezzik
go-licenses save ./cmd/reword --save_path=license-files_reword --ignore github.com/inigolabs/fezzik
go-licenses save ./cmd/spr --save_path=license-files_spr --ignore github.com/inigolabs/fezzik
