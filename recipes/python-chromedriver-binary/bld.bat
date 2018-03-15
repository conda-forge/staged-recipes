python %RECIPE_DIR%\download-chromedriver 
if errorlevel 1 exit 1

7z x chromedriver.zip -ochromedriver
if errorlevel 1 exit 1

REM Add chromedriver to PATH so chromedriver_binary install can find it
set PATH=%PATH%:%CD%\chromedriver
python -m pip install --no-deps --ignore-installed .
