#! /bin/sh

# The catalog maps URIs to paths in the environment.  This necessarily
# hardcodes the XSL stylesheet base URI
# (http://cdn.docbook.org/release/xsl/), because that that is how
# stylesheets are identified
# (e.g. http://cdn.docbook.org/release/xsl/current/html/docbook.xsl).

if ! test -r "${PREFIX}/etc/xml/catalog" ; then
    mkdir -p "${PREFIX}/etc/xml"
    xmlcatalog --noout --create "${PREFIX}/etc/xml/catalog"
fi

xmlcatalog --noout --add "delegateSystem"            \
    "http://cdn.docbook.org/release/xsl/"            \
    "file://${PREFIX}/share/${PKG_NAME}/catalog.xml" \
    "${PREFIX}/etc/xml/catalog"
xmlcatalog --noout --add "delegateURI"               \
    "http://cdn.docbook.org/release/xsl/"            \
    "file://${PREFIX}/share/${PKG_NAME}/catalog.xml" \
    "${PREFIX}/etc/xml/catalog"
