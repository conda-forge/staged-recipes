# Build script for libp11, referenced from recipe.yaml via
# `build: script: file:`. Runs with the build and host prefixes
# activated; pkgconf (build) locates the OpenSSL (host) headers and
# libraries.
set -eu

./configure --prefix=$PREFIX
make
make install
