#!/bin/bash

set -exuo pipefail

mkdir gopath
export GOPATH=$(pwd)/gopath

make brew
make install