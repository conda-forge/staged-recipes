:: Just delegate to the Unixy script; but some of the X.org tarballs have
:: config.guess files too ancient to recognize 64-bit Windows!
curl -sSL -o config.guess https://raw.githubusercontent.com/gcc-mirror/gcc/master/config.guess
if errorlevel 1 exit 1
bash %RECIPE_DIR%\build.sh
if errorlevel 1 exit 1
