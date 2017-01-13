:: Just delegate to the Unixy script; but some of the X.org tarballs have
:: config.guess files too ancient to recognize 64-bit Windows!
curl -sSL -o config.guess "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess"
curl -sSL -o config.sub "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub"
if errorlevel 1 exit 1
bash %RECIPE_DIR%\build.sh
if errorlevel 1 exit 1
