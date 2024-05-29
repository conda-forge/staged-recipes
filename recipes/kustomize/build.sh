#!/bin/sh

set -xeu

cd kustomize
go build -ldflags \
    "-X sigs.k8s.io/kustomize/api/provenance.buildDate=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
    -X sigs.k8s.io/kustomize/api/provenance.version=v${PKG_VERSION}" \
    .

INSTALLDIR="${LIBRARY_BIN:-$PREFIX/bin}"
mkdir "${INSTALLDIR}"
cp kustomize "${INSTALLDIR}/kustomize${LIBRARY_BIN:+.exe}"
