#!/usr/bin/env bash

#export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${PREFIX}/lib"
export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH
#export LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:/usr/local/lib64:/usr/lib64
#
#export GO111MODULE=on
#export CGO_ENABLED=0

#bazel run //:gazelle -- update-repos -from_file=go.mod
bazel build --platforms=@io_bazel_rules_go//go/toolchain:linux_amd64 runsc --verbose_failures

