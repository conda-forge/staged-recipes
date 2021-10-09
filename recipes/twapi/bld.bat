set TCL_LIB_PATH=%PREFIX%\Library\lib\%PKG_NAME%%PKG_VERSION%
mkdir %TCL_LIB_PATH%
xcopy *.* %TCL_LIB_PATH%\

