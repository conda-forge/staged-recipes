@echo off

set "URI=%PREFIX:\=/%"
xmlcatalog --noout --del                         ^
    "file:///%URI%/share/%PKG_NAME%/catalog.xml" ^
    "%PREFIX%\etc\xml\catalog"
