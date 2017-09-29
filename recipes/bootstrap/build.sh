#!/bin/bash

npm run build
[[ -d "${PREFIX}"/static ]] && rm -rf "${PREFIX}"/static
mkdir -p "${PREFIX}"/static/${PKG_NAME%_static}/${PKG_VERSION}
cp -rf dist/* "${PREFIX}"/static/${PKG_NAME%_static}/${PKG_VERSION}/
