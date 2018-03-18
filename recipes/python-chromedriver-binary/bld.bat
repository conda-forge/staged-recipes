python %RECIPE_DIR%\download-chromedriver.py
if errorlevel 1 exit 1

REM Add chromedriver to PATH so chromedriver_binary install can find it
set PATH=%PATH%;%CD%\chromedriver
python -m pip install --no-deps --ignore-installed .
