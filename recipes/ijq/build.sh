#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make prefix=${PREFIX} install
go-licenses save . --save_path=license-files --ignore git.sr.ht/~gpanders/ijq
