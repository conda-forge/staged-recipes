mkdir %LIBRARY_BIN%
xcopy %SRC_DIR%\binary-winpthread\ucrt64\bin\* %LIBRARY_BIN%\ /s /e /y
xcopy %SRC_DIR%\binary-gcc\ucrt64\bin\* %LIBRARY_BIN%\ /s /e /y
xcopy %SRC_DIR%\binary-gfortran\ucrt64\bin\* %LIBRARY_BIN%\ /s /e /y
