#!/usr/bin/env bash

set -xeuo pipefail

cd kustomize
go build -ldflags \
    "-X sigs.k8s.io/kustomize/api/provenance.buildDate=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
    -X sigs.k8s.io/kustomize/api/provenance.version=v${PKG_VERSION}" \
    .

go-licenses save . --save_path="./license-files/"

INSTALLDIR="${PREFIX}/bin"
mkdir "${INSTALLDIR}"
cp kustomize "${INSTALLDIR}/"
