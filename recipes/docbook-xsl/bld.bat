@echo off

md "%PREFIX%\share\%PKG_NAME%"
if errorlevel 1 exit /b 1

for %%i in ( "assembly"     ^
             "common"       ^
             "eclipse"      ^
             "epub"         ^
             "epub3"        ^
             "fo"           ^
             "highlighting" ^
             "html"         ^
             "htmlhelp"     ^
             "images"       ^
             "javahelp"     ^
             "lib"          ^
             "manpages"     ^
             "profiling"    ^
             "roundtrip"    ^
             "slides"       ^
             "template"     ^
             "website"      ^
             "xhtml"        ^
             "xhtml-1_1"    ^
             "xhtml5" ) do (
    robocopy "%SRC_DIR%\\%%i" "%PREFIX%\share\%PKG_NAME%\\%%i" /e
    if not errorlevel 1 exit /b 1
)

robocopy "%SRC_DIR%" "%PREFIX%\share\%PKG_NAME%" ^
    "VERSION"                                    ^
    "VERSION.xsl"                                ^
    "catalog.xml"
if not errorlevel 1 exit /b 1

