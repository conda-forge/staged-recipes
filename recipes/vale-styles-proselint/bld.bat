@echo on
set VALE_STYLES_PATH=%PREFIX%\share\vale\styles
md "%VALE_STYLES_PATH%"

copy "%RECIPE_DIR%\.vale.ini" .vale.ini

vale sync || exit 1
vale ls-config || exit 1
vale ls-dirs || exit 1

copy "LICENSE-vale-proselint-0.3.3" LICENSE || exit 1
