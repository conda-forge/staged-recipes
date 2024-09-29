#!/bin/bash

set -exuo pipefail

# chmod -R 777 /home/uenom/Projects/staged-recipes/recipes/yash/output

# mkdir -p ${PREFIX}/etc/xml
# cp "${RECIPE_DIR}/catalog.xml" "${PREFIX}/etc/xml/catalog"
# # export XML_CATALOG_FILES="${PREFIX}/etc/xml/catalog"

# # mkdir -p ${PREFIX}/bin/
# # mkdir -p ${PREFIX}/share/

# # rm ${PREFIX}/etc/asciidoc/docbook-xsl/manpage.xsl
# # cp ${PREFIX}/etc/xml/catalog ${PREFIX}/etc/asciidoc/docbook-xsl/

# echo $XML_CATALOG_FILES
# # test -f $XML_CATALOG_FILES

./configure --prefix="${PREFIX}"
make install-binary
