python download-chromedriver.py
mkdir chromedriver
gzip -dc < chromedriver.zip > chromedriver/chromedriver
chmod 755 chromedriver/chromedriver
# Add chromedriver to PATH so chromedriver_binary install can find it
export PATH=$PATH:$PWD/chromedriver
python -m pip install --no-deps --ignore-installed .
