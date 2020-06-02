#!/bin/sh

export GOPATH="$RECIPE_DIR/go"

go get bou.ke/staticfiles
$GOPATH/bin/staticfiles -o server/static/files.go ui/dist/app

export CGO_ENABLED=0 
export GOARCH=amd64

if [ "$(uname)" == "Darwin" ]; then
    export GOOS=darwin 
else
    export GOOS=linux 
fi

go build -v -i -ldflags '-extldflags "-static" -X github.com/argoproj/argo.version=$VERSION' -o dist/argo ./cmd/argo

mkdir -p $HOME/bin
mv dist/argo $HOME/bin
