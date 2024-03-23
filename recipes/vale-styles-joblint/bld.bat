@echo on
set VALE_STYLES_PATH=%PREFIX%\share\vale\styles
md "%VALE_STYLES_PATH%"

echo "Packages = ./Joblint" >> .vale.ini
echo "StylesPath = %VALE_STYLES_PATH%" >> .vale.ini

copy "LICENSE-vale-Joblint-0.4.1" LICENSE || exit 1

vale sync || exit 1
vale ls-config || exit 1
vale ls-dirs || exit 1
