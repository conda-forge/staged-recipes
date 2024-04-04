#!/bin/bash

set -exuo pipefail

mkdir -p gopath/bin
export GOPATH=$(pwd)/gopath

export PULUMI_VERSION=${PKG_VERSION}

make brew
