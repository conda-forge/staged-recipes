echo "tkimg building"
copy %RECIPE_DIR%\build.sh build.sh
sh build.sh

rem set TCL_LIB_PATH=%PREFIX%\Library\lib\%PKG_NAME%%PKG_VERSION%
rem mkdir %TCL_LIB_PATH% || exit /b 1
rem xcopy ImgBinary\*.* %TCL_LIB_PATH%\ || exit /b 1
rem xcopy ImgSource\license.terms %TCL_LIB_PATH%\ || exit /b 1
