#!/bin/sh

mkdir -p ui/node_modules
yarn --cwd ui install --frozen-lockfile --ignore-optional --non-interactive

mkdir -p ui/dist/app
yarn --cwd ui build

# This could be a conda-package as a build requirement
go get bou.ke/staticfiles
staticfiles -o server/static/files.go ui/dist/app
# It did its job, so we remove it now...
rm $PREFIX/bin/staticfiles

go install -v -i -ldflags '-extldflags "-static" -X github.com/argoproj/argo.version=$VERSION' ./cmd/argo
