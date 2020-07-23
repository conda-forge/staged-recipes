#!/bin/bash

export CGO_ENABLED=1
go install -mod vendor -ldflags "-X 'github.com/tilt-dev/tilt/internal/cli.commitSHA={{ commit }}'" ./cmd/tilt/...
