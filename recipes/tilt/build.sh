#!/bin/bash

if [[ $(uname) = "Darwin" ]]; then
    export CGO_ENABLED=1
fi
go install -mod vendor -ldflags "-X 'github.com/tilt-dev/tilt/internal/cli.commitSHA={{ commit }}'" ./cmd/tilt/...
