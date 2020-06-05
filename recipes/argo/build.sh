#!/bin/sh
set -euf

yarn --cwd ui install --frozen-lockfile --ignore-optional --non-interactive
yarn --cwd ui build

# This could be a conda-package as a build requirement
# then we would not reed to remove it
go get bou.ke/staticfiles
staticfiles -o server/static/files.go ui/dist/app
rm $PREFIX/bin/staticfiles

go install -v -i -ldflags '-extldflags "-static" -X github.com/argoproj/argo.version=$VERSION' ./cmd/argo