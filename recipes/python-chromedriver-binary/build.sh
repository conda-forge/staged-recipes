curl -O https://chromedriver.storage.googleapis.com/2.36/chromedriver_linux64.zip 
gzip -dc < chromedriver_linux64.zip > chromedriver
chmod 755 chromedriver
python -m pip install --no-deps --ignore-installed .
