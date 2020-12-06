#!/usr/bin/env bash
# derived from https://github.com/2m/coursier-pkgbuild/blob/master/PKGBUILD
set -eux

export COURSIER_CACHE="$SRC_DIR/cache"

mkdir -p $COURSIER_CACHE

bash ./coursier \
    bootstrap \
    "io.get-coursier::coursier-cli:${PKG_VERSION}" \
    --java-opt "-noverify" \
    --no-default \
    -r central \
    -r typesafe:ivy-releases \
    -f -o "$PREFIX/bin/coursier" \
    --standalone
