#!/bin/bash

set -euxo pipefail

export CGO_ENABLED=0

# upstream's buildscripts/gen-ldflags.go calls `git log`, which fails on a tarball
# source, so reproduce its flags from the release tag and commit set in recipe.yaml
release_date="${RELEASE%%T*}"
release_time="${RELEASE#*T}"
VERSION="${release_date}T${release_time//-/:}"
LDFLAGS="-s -w"
LDFLAGS+=" -X github.com/minio/minio/cmd.Version=${VERSION}"
LDFLAGS+=" -X github.com/minio/minio/cmd.CopyrightYear=${RELEASE:0:4}"
LDFLAGS+=" -X github.com/minio/minio/cmd.ReleaseTag=RELEASE.${RELEASE}"
LDFLAGS+=" -X github.com/minio/minio/cmd.CommitID=${GIT_COMMIT}"
LDFLAGS+=" -X github.com/minio/minio/cmd.ShortCommitID=${GIT_COMMIT:0:12}"

mkdir -p "${PREFIX}/bin"
go build -tags kqueue -trimpath -ldflags "${LDFLAGS}" -o "${PREFIX}/bin/silo"

go-licenses save . \
    --save_path="${SRC_DIR}/library_licenses"  \
    --ignore github.com/apache/thrift/lib/go/thrift \
    --ignore github.com/minio/colorjson \
    --ignore github.com/minio/csvparser \
    --ignore github.com/minio/filepath \
    --ignore github.com/minio/console \
    --ignore github.com/minio/dperf \
    --ignore github.com/minio/kms-go/kes \
    --ignore github.com/minio/kms-go/kms \
    --ignore github.com/minio/mc \
    --ignore  github.com/minio/madmin-go/v3 \
    --ignore github.com/minio/minio \
    --ignore github.com/minio/pkg/v3 \
    --ignore github.com/pgsty/silo-pkg/v3

# allow conda to clean up the read-only go module cache
chmod -R u+w "$(go env GOPATH)"
