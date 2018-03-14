curl -O https://chromedriver.storage.googleapis.com/2.36/chromedriver_linux64.zip 
mkdir chromedriver
gzip -dc < chromedriver_linux64.zip > chromedriver/chromedriver
chmod 755 chromedriver/chromedriver
export PATH=$PATH:$PWD/chromedriver
python -m pip install --no-deps --ignore-installed .
