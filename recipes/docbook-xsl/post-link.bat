@echo off

:: See post-link.sh.

if not exist "%PREFIX%\etc\xml\catalog" (
    md "%PREFIX%\etc\xml"
    xmlcatalog --noout --create "%PREFIX%\etc\xml\catalog"
)

set "URI=%PREFIX:\=/%"
xmlcatalog --noout --add "delegateSystem"        ^
    "http://cdn.docbook.org/release/xsl/"        ^
    "file:///%URI%/share/%PKG_NAME%/catalog.xml" ^
    "%PREFIX%\etc\xml\catalog"
xmlcatalog --noout --add "delegateURI"           ^
    "http://cdn.docbook.org/release/xsl/"        ^
    "file:///%URI%/share/%PKG_NAME%/catalog.xml" ^
    "%PREFIX%\etc\xml\catalog"
