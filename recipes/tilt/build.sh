#!/bin/bash
# Metadata taken from https://github.com/tilt-dev/tilt/releases/tag/v0.14.3
DATE=2020-06-12
VERSION="0.14.3"
COMMIT=329e43fd9c18e87c48e643109b88852bdbef0e36

mkdir -p $PREFIX/bin
export GOPATH=$PREFIX

go install \
    -tags=osusergo -mod=vendor \
    -ldflags="-s -w -X main.version=$VERSION -X main.commit=$COMMIT -X main.date=$DATE" \
    ./cmd/tilt/...

