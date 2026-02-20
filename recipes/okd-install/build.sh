#!/bin/bash
set -euo pipefail

# OpenShift Installer Build Script
# https://github.com/openshift/installer/blob/main/hack/build.sh
#
go-licenses save ./cmd/openshift-install --save_path ./library_licenses/

# Build cluster-api providers (equivalent to make go-build)
export TARGET_OS_ARCH="$(go env GOOS)_$(go env GOARCH)"
# export GCFLAGS="all=-N -l"
export GCFLAGS=""
export CLUSTER_API_BIN_DIR="$(pwd)/cluster-api/bin/${TARGET_OS_ARCH}"
export CLUSTER_API_MIRROR_DIR="$(pwd)/pkg/cluster-api/mirror/"
export ENVTEST_K8S_VERSION="1.32.0"
export ENVTEST_ARCH="$(go env GOOS)_$(go env GOARCH)"

mkdir -p "$CLUSTER_API_BIN_DIR"
mkdir -p "$CLUSTER_API_MIRROR_DIR"

# Build AWS provider
go build \
    -C cluster-api/providers/aws \
    -gcflags "$GCFLAGS" -ldflags "-s -w" \
    -o "$CLUSTER_API_BIN_DIR/cluster-api-provider-aws" \
    ./vendor/sigs.k8s.io/cluster-api-provider-aws/v2

# Build Azure provider
go build \
    -C cluster-api/providers/azure \
    -gcflags "$GCFLAGS" -ldflags "-s -w" \
    -o "$CLUSTER_API_BIN_DIR/cluster-api-provider-azure" \
    ./vendor/sigs.k8s.io/cluster-api-provider-azure

# Build AzureASO provider
go build \
    -C cluster-api/providers/azureaso \
    -gcflags "$GCFLAGS" -ldflags "-s -w" \
    -o "$CLUSTER_API_BIN_DIR/cluster-api-provider-azureaso" \
    ./vendor/github.com/Azure/azure-service-operator/v2/cmd/controller

# Build AzureStack provider
go build \
    -C cluster-api/providers/azurestack \
    -gcflags "$GCFLAGS" -ldflags "-s -w" \
    -o "$CLUSTER_API_BIN_DIR/cluster-api-provider-azurestack" \
    ./vendor/sigs.k8s.io/cluster-api-provider-azure

# Build GCP provider
go build \
    -C cluster-api/providers/gcp \
    -gcflags "$GCFLAGS" -ldflags "-s -w" \
    -o "$CLUSTER_API_BIN_DIR/cluster-api-provider-gcp" \
    ./vendor/sigs.k8s.io/cluster-api-provider-gcp

# Build IBMCloud provider
go build \
    -C cluster-api/providers/ibmcloud \
    -gcflags "$GCFLAGS" -ldflags "-s -w" \
    -o "$CLUSTER_API_BIN_DIR/cluster-api-provider-ibmcloud" \
    ./vendor/sigs.k8s.io/cluster-api-provider-ibmcloud

# Build Nutanix provider
go build \
    -C cluster-api/providers/nutanix \
    -gcflags "$GCFLAGS" -ldflags "-s -w" \
    -o "$CLUSTER_API_BIN_DIR/cluster-api-provider-nutanix" \
    ./vendor/github.com/nutanix-cloud-native/cluster-api-provider-nutanix

# Build OpenStack provider
go build \
    -C cluster-api/providers/openstack \
    -gcflags "$GCFLAGS" -ldflags "-s -w" \
    -o "$CLUSTER_API_BIN_DIR/cluster-api-provider-openstack" \
    ./vendor/sigs.k8s.io/cluster-api-provider-openstack

# Build vSphere provider
go build \
    -C cluster-api/providers/vsphere \
    -gcflags "$GCFLAGS" -ldflags "-s -w" \
    -o "$CLUSTER_API_BIN_DIR/cluster-api-provider-vsphere" \
    ./vendor/sigs.k8s.io/cluster-api-provider-vsphere

# Build main cluster-api binary (equivalent to make go-build-cluster-api)
go build \
    -C cluster-api/cluster-api \
    -gcflags "$GCFLAGS" -ldflags "-s -w" \
    -o "$CLUSTER_API_BIN_DIR/cluster-api" \
    ./vendor/sigs.k8s.io/cluster-api

# I presume we skip the ENVTEST at least until we have a proper kub-apiserver.

# Zip every binary in the folder into a single zip file (if any exist)
zip -j1 "cluster-api.zip" $CLUSTER_API_BIN_DIR/*

# Build okd-install
go build -o $PREFIX/bin/openshift-install \
    -ldflags "-s -w -X github.com/openshift/installer/pkg/version.Raw=$PKG_VERSION -X github.com/openshift/installer/pkg/version.Commit=$PKG_VERSION" \
    -tags "include_gcs include_oss containers_image_openpgp" \
    ./cmd/openshift-install

# Create okd-install symlink
cp $PREFIX/bin/openshift-install $PREFIX/bin/okd-install
