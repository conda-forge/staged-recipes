python download-chromedriver
7z x chromedriver.zip -ochromedriver
REM Add chromedriver to PATH so chromedriver_binary install can find it
set PATH=%PATH%:%CD%\chromedriver
python -m pip install --no-deps --ignore-installed .
