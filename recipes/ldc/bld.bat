dir

7za x ldc2-%PKG_VERSION%-windows-x64.7z -o%SRC_DIR%\

xcopy /S /I /E %SRC_DIR%\ldc2-%PKG_VERSION%-windows-x64 %LIBRARY_PREFIX%
