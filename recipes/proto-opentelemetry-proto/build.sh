#!/bin/bash

set -ex

main() {
    local -r dest_dir="$PREFIX/share/opentelemetry/opentelemetry-proto"
    mkdir -p "$dest_dir"
    cp LICENSE "$dest_dir"
    cp -r opentelemetry "$dest_dir/opentelemetry"
}

main
