#!/bin/bash
#
# Create an empty egg-info file to declare lalsuite to pip
#

set -ex
touch ${SP_DIR}/${PKG_NAME}-${PKG_VERSION}-py${PY_VER}.egg-info
