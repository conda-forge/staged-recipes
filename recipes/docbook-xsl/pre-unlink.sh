#! /bin/sh

xmlcatalog --noout --del                             \
    "file://${PREFIX}/share/${PKG_NAME}/catalog.xml" \
    "${PREFIX}/etc/xml/catalog"
