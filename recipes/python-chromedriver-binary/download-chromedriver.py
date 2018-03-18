import os
import sys
import subprocess
import zipfile

pkg_version = os.environ['PKG_VERSION']
driver_version = "{0}.{1}".format(*pkg_version.split("."))
if sys.platform == 'win32':
    chromedriver_pkg = 'chromedriver_win32.zip'
elif sys.platform == 'darwin':
    chromedriver_pkg = 'chromedriver_mac64.zip'
else:
    chromedriver_pkg = 'chromedriver_linux64.zip'

download_url = 'https://chromedriver.storage.googleapis.com/{0}/{1}'.format(driver_version, chromedriver_pkg)

subprocess.check_call('curl "{}" -o chromedriver.zip'.format(download_url), shell=True)

os.mkdir('chromedriver')
with zipfile.ZipFile('chromedriver.zip') as chromedriver_zip_file:
    chromedriver_zip_file.extractall('chromedriver')
