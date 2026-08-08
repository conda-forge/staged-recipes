#!/bin/bash
set -euo pipefail

# OpenShift Installer Build Script
# https://github.com/openshift/installer/blob/main/hack/build.sh
#
go-licenses save ./cmd/openshift-install --save_path ./library_licenses/

# Build cluster API binaries first
# Unset C-linker LDFLAGS so they don't interfere with Go's cgo/make build
unset LDFLAGS
. ${SRC_DIR}/hack/build-cluster-api.sh
make -C cluster-api all
copy_cluster_api_to_mirror

# Build okd-install
go build -o $PREFIX/bin/openshift-install \
    -ldflags "-s -w -X github.com/openshift/installer/pkg/version.Raw=$PKG_VERSION -X github.com/openshift/installer/pkg/version.Commit=$PKG_VERSION" \
    -tags "include_gcs include_oss containers_image_openpgp" \
    ./cmd/openshift-install

# Create okd-install symlink
cp $PREFIX/bin/openshift-install $PREFIX/bin/okd-install
