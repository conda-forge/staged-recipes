#! /bin/sh

test -d "${PREFIX}/share/${PKG_NAME}"
echo "system http://cdn.docbook.org/release/xsl/current/" \
    | xmlcatalog --shell                                  \
    | grep "^> file://"
