#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ ${target_platform} =~ .*osx.* ]]; then
    go build -buildmode=pie -trimpath -o=${PREFIX}/bin/docker-credential-osxkeychain -ldflags="-s -w" ./osxkeychain/cmd
    go-licenses save ./osxkeychain/cmd --save_path=license-files
else
    go build -buildmode=pie -trimpath -o=${PREFIX}/bin/docker-credential-pass -ldflags="-s -w" ./pass/cmd
    go-licenses save ./pass/cmd --save_path=license-files_pass
    go build -buildmode=pie -trimpath -o=${PREFIX}/bin/docker-credential-secretservice -ldflags="-s -w" ./secretservice/cmd
    go-licenses save ./secretservice/cmd --save_path=license-files_secretservice
fi
