#! /bin/sh

mkdir -p "${PREFIX}/share/${PKG_NAME}"
for i in "assembly"     \
         "common"       \
         "eclipse"      \
         "epub"         \
         "epub3"        \
         "fo"           \
         "highlighting" \
         "html"         \
         "htmlhelp"     \
         "images"       \
         "javahelp"     \
         "lib"          \
         "manpages"     \
         "profiling"    \
         "roundtrip"    \
         "slides"       \
         "template"     \
         "website"      \
         "xhtml"        \
         "xhtml-1_1"    \
         "xhtml5" ; do
    cp -pr "${SRC_DIR}/${i}" "${PREFIX}/share/${PKG_NAME}"
done

cp -p "VERSION"     \
      "VERSION.xsl" \
      "catalog.xml" \
    "${PREFIX}/share/${PKG_NAME}"
