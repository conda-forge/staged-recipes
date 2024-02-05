rem
rem prefix, name, version
set prefix=%PREFIX%
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
tar -xzf xrst-%version%.tar.gz
cd xrst-%version%
rem
rem xrst-%version%\pytest\test_rst.py
sed -i pytest\test_rst.py ^
   -e  "s|'python3' *,.*|'%prefix%\Scripts', '--suppress_spell_warnings', |" ^
   pytest\test_rst.py ^
rem
rem xrst-%version%\xrst.toml
sed -i -e "s|pyenchant|pyspellchecker|" xrst.toml
rem
rem pytest
pytest -s pytest
if %ERRORLEVEL% NEQ 0 (
   echo 'run_test.bat: Error'
) ELSE (
   echo 'run_test.bak: Error'
)

