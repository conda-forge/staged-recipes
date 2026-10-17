#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make ARGON2_VERSION="${PKG_VERSION}" OPTTARGET='none' LIBRARY_REL='lib' install
make test
