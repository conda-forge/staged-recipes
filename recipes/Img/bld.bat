set TCL_LIB_PATH=%PREFIX%\Library\lib\%PKG_NAME%%PKG_VERSION%
mkdir %TCL_LIB_PATH% || exit /b 1
xcopy ImgBinary\*.* %TCL_LIB_PATH%\ || exit /b 1
xcopy ImgSource\license.terms %TCL_LIB_PATH%\ || exit /b 1
