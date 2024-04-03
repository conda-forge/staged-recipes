#!/bin/bash

set -exuo pipefail

mkdir -p gopath/bin
export GOPATH=$(pwd)/gopath

make brew