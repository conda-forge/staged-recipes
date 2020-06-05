#!/bin/sh

mkdir -p ui/node_modules
yarn --cwd ui install --frozen-lockfile --ignore-optional --non-interactive

mkdir -p ui/dist/app
yarn --cwd ui build

# This could be a conda-package as a build requirement
go get bou.ke/staticfiles
staticfiles -o server/static/files.go ui/dist/app

go install -v -i -ldflags '-extldflags "-static" -X github.com/argoproj/argo.version=$VERSION' ./cmd/argo

# Because bou.ke/staticfiles is not in conda
rm $PREFIX/bin/staticfiles
