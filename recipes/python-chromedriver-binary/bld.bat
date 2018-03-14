curl -O https://chromedriver.storage.googleapis.com/2.36/chromedriver_win32.zip
7za x chromedriver.zip -ochromedriver
export PATH=$PATH:$CD/chromedriver
python -m pip install --no-deps --ignore-installed .
