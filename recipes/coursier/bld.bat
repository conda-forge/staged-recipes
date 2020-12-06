@echo on
:: derived from https://github.com/2m/coursier-pkgbuild/blob/master/PKGBUILD
set COURSIER_CACHE=%SRC_DIR%\cache

md /s /q %COURSIER_CACHE%

courser --help

coursier ^
    bootstrap ^
    "io.get-coursier::coursier-cli:%PKG_VERSION%" ^
    --java-opt "-noverify" ^
    --no-default ^
    -r central ^
    -r typesafe:ivy-releases ^
    -f -o "%PREFIX%\Scripts\coursier.bat" ^
    --standalone
