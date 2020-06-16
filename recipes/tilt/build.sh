#!/bin/bash
#
# Tilt installer
#
# Adapted from https://raw.githubusercontent.com/tilt-dev/tilt/v0.14.3/scripts/install.sh

VERSION="0.14.3"
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  set -x
  curl -fsSL https://github.com/tilt-dev/tilt/releases/download/v$VERSION/tilt.$VERSION.linux.x86_64.tar.gz | tar -xzv tilt
elif [[ "$OSTYPE" == "darwin"* ]]; then
  set -x
  curl -fsSL https://github.com/tilt-dev/tilt/releases/download/v$VERSION/tilt.$VERSION.mac.x86_64.tar.gz | tar -xzv tilt
fi

mkdir -p $PREFIX/bin
cp tilt $PREFIX/bin
