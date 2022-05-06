#!/bin/bash
mkdir -p $PREFIX/bin
GOARCH=amd64 GOOS=linux GOPATH="" go build -o $PREFIX/bin/gopeaks gopeaks.go
chmod a+x $PREFIX/bin/gopeaks


