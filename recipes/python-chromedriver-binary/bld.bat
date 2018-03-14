curl -O https://chromedriver.storage.googleapis.com/2.36/chromedriver_win32.zip
7za x chromedriver.zip -ochromedriver
REM Add chromedriver to PATH so chromedriver_binary install can find it
set PATH=%PATH%:%CD%/chromedriver
python -m pip install --no-deps --ignore-installed .
