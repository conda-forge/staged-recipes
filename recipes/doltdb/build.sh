#!/usr/bin/env bash
export GOBIN=${PREFIX}/bin
cd go
go install ./cmd/dolt
go install ./utils/remotesrv
