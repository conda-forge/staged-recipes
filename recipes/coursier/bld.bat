@echo on
:: derived from https://github.com/2m/coursier-pkgbuild/blob/master/PKGBUILD
set "COURSIER_CACHE=%SRC_DIR%\cache"

md "%COURSIER_CACHE%" || goto :ERROR
md "%SCRIPTS%" || goto :ERROR

call coursier ^
    bootstrap ^
    "io.get-coursier::coursier-cli:%PKG_VERSION%" ^
    --java-opt "-noverify" ^
    --no-default ^
    -r central ^
    -r typesafe:ivy-releases ^
    -f -o "%SCRIPTS%\coursier.bat" ^
    --standalone ^
    || goto :ERROR

goto :EOF

:ERROR
echo FAIL Building %PKG_NAME% with error #%errorlevel%.
exit /b 1
