#!/usr/bin/env bash

set -euo pipefail

cd kustomize
go build -ldflags \
    "-X sigs.k8s.io/kustomize/api/provenance.buildDate=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
    -X sigs.k8s.io/kustomize/api/provenance.version=v${PKG_VERSION}" \
    .

mkdir "${PREFIX}/bin"
cp kustomize "${PREFIX}/bin/"
