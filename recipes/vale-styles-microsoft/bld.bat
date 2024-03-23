@echo on
set VALE_STYLES_PATH=%PREFIX%\share\vale\styles
md "%VALE_STYLES_PATH%"

echo "Packages = ./Microsoft" >> .vale.ini
echo "StylesPath = %VALE_STYLES_PATH%" >> .vale.ini

copy "LICENSE-vale-Microsoft-0.14.0" LICENSE || exit 1

vale sync || exit 1
vale ls-config || exit 1
vale ls-dirs || exit 1
