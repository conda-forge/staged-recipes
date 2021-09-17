#!/bin/bash
set -ex

# for subpackages, we have named our extracted locations according to the subpackage name
#    That's what this $PKG_NAME is doing - picking the right subfolder to rsync

src="${SRC_DIR}/${PKG_NAME}"

cp -rv "${src}"/* "${PREFIX}/"

# replace old info folder with our new regenerated one
rm -rf "${PREFIX}/info"
