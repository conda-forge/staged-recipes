mkdir %PREFIX%\Library\ucrt64
xcopy %SRC_DIR%\binary-%PKG_NAME%\ucrt64 %LIBRARY_PREFIX%\ucrt64 /s /e /y
