@echo on

set COURSIER_CACHE=%SRC_DIR%\cache

md /s /q %COURSIER_CACHE%

.\coursier.bat ^
    bootstrap ^
    "io.get-coursier::coursier-cli:%PKG_VERSION%" ^
    --java-opt "-noverify" ^
    --no-default ^
    -r central ^
    -r typesafe:ivy-releases ^
    -f -o "%PREFIX%\Scripts\coursier.bat" ^
    --standalone
