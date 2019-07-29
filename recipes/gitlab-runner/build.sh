#!/bin/bash

set -x

# get variables
PKG="gitlab.com/gitlab-org/${PKG_NAME}"
REVISION="${GIT_DESCRIBE_HASH}"
IFS='.' read -r -a VERSION_PARTS <<< "${PKG_VERSION}"
BRANCH="${VERSION_PARTS[0]}-${VERSION_PARTS[1]}-stable"
BUILT=$(date -u +%Y-%m-%dT%H:%M:%S%:z)

# build
GOPATH="${SRC_DIR}"
go build \
	-ldflags \
		"-X ${PKG}/common.NAME=${PKG_NAME} \
		-X ${PKG}/common.VERSION=${PKG_VERSION} \
		-X ${PKG}/common.REVISION=${REVISION} \
		-X ${PKG}/common.BRANCH=${BRANCH} \
		-X ${PKG}/common.BUILT=${BUILT}" \
	${PKG}

# install
install gitlab-runner "${PREFIX}/bin"
