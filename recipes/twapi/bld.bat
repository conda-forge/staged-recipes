set TCL_LIB_PATH=%LIBRARY_LIB%\%PKG_NAME%%PKG_VERSION%
mkdir %TCL_LIB_PATH% || exit /b 1
xcopy *.* %TCL_LIB_PATH%\ || exit /b 1

