#! /bin/sh

test -d "${PREFIX}/share/${PKG_NAME}"


# This should not be necessary if
# https://github.com/conda-forge/libxslt-feedstock/pull/36 is merged.
export XML_CATALOG_FILES="${PREFIX}/etc/xml/catalog"

echo "system http://cdn.docbook.org/release/xsl/current/" \
    | xmlcatalog --shell                                  \
    | grep "^> file://"
