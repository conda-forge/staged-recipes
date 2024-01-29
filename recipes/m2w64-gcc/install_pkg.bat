mkdir %PREFIX%\Library\mingw-w64
xcopy %SRC_DIR%\binary-%PKG_NAME%\ucrt64 %LIBRARY_PREFIX%\mingw-w64 /s /e /y
