#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go mod init github.com/docker/cli
go mod edit -replace github.com/imdario/mergo@v1.0.0=github.com/imdario/mergo@v0.3.16
go mod tidy -e
go mod vendor -e
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/docker -ldflags="-s -w" ./cmd/docker

mkdir -p ${PREFIX}/etc/bash_completion.d
mkdir -p ${PREFIX}/share/zsh/site-functions
mkdir -p ${PREFIX}/share/fish/vendor_completions.d
install -m 644 contrib/completion/bash/docker ${PREFIX}/etc/bash_completion.d/docker
install -m 644 contrib/completion/fish/docker.fish ${PREFIX}/share/fish/vendor_completions.d/docker.fish
install -m 644 contrib/completion/zsh/_docker ${PREFIX}/share/zsh/site-functions/_docker

mkdir -p ${PREFIX}/share/man/man1
mkdir -p ${PREFIX}/share/man/man5
mkdir -p ${PREFIX}/share/man/man8
go-md2man -in=man/docker.1.md -out=${PREFIX}/share/man/man1/docker.1
go-md2man -in=man/docker-build.1.md -out=${PREFIX}/share/man/man1/docker-build.1
go-md2man -in=man/docker-run.1.md -out=${PREFIX}/share/man/man1/docker-run.1
go-md2man -in=man/Dockerfile.5.md -out=${PREFIX}/share/man/man5/Dockerfile.1
go-md2man -in=man/docker-config-json.5.md -out=${PREFIX}/share/man/man5/docker-config-json.5
go-md2man -in=man/dockerd.8.md -out=${PREFIX}/share/man/man8/dockerd.8

go-licenses save ./cmd/docker --save_path=license-files
