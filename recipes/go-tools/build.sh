#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

build_cmd() {
    cmd_name=$1
    cmd_prefix=${cmd_name:0:2}
    if [[ ${cmd_prefix} != "go" ]]; then
        bin_name="go-${cmd_name//\//-}"
    else
        bin_name=${cmd_name//\//-}
    fi
    go build -modcacherw -buildmode=pie -trimpath -o=${PREFIX}/bin/${bin_name} -ldflags="-s -w" ./cmd/${cmd_name}
    go-licenses save ./cmd/${cmd_name} --save_path=license-files/${cmd_name}
}

export -f build_cmd

cmd_names=(
    auth/authtest
    auth/cookieauth
    auth/gitauth
    auth/netrcauth
    bisect
    bundle
    callgraph
    compilebench
    deadcode
    digraph
    eg
    file2fuzz
    fiximports
    go-contrib-init
    godex
    godoc
    goimports
    gomvpkg
    gonew
    gotype
    goyacc
    html2article
    present
    present2md
    signature-fuzzer/fuzz-driver
    signature-fuzzer/fuzz-runner
    splitdwarf
    ssadump
    stress
    stringer
    toolstash
)

echo ${cmd_names[@]} | tr ' ' '\n' | xargs -I % bash -c "build_cmd %"
