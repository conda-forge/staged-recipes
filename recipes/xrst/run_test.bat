rem
rem name, version
set name=%PKG_NAME%
set version=%PKG_VERSION%
rem
rem url
set home="https://github.com/bradbell/%name%"
set url="%home%/archive/%version%.tar.gz"
rem
rem xrst-%version%.tar.gz
curl -LJO %url%
rem
rem xrst-%version%
rem we get a copy of the original source because it has an automated test.
tar -xzf xrst-%version%.tar.gz
cd xrst-%version%
rem
rem xrst-%version%\pytest\test_rst.py
rem It is hard to use PREFIX here becasue dos uses \ for directory separator.
rem Using xrst.exe (instead of xrst) ensures we are running installed version
rem and not the version in this source.
sed -e  "s|'python3' *,.*|'xrst.exe', '--suppress_spell_warnings', |" ^
   ..\pytest\test_rst.py > pytest\test_rst.py
rem
rem xrst-%version%\xrst.toml
sed -i -e "s|pyenchant|pyspellchecker|" xrst.toml
rem
rem pytest
pytest -s pytest
IF %ERRORLEVEL% NEQ 0 (
   CD ..
   ECHO run_test.bat Error
   exit /B 1
)
CD ..
ECHO run_test.bat: OK

