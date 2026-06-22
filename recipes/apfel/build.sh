#!/bin/bash
set -euo pipefail

# The upstream tarball embeds xattr/pax headers that extract as AppleDouble
# resource-fork files (._*); strip them so they don't ship in the package.
find . -name '._*' -delete

install -d "${PREFIX}/bin"
install -m 755 apfel "${PREFIX}/bin/apfel"

install -d "${PREFIX}/share/man/man1"
install -m 644 apfel.1 "${PREFIX}/share/man/man1/apfel.1"

install -d "${PREFIX}/share/apfel/demo"
cp -r demo/. "${PREFIX}/share/apfel/demo/"
