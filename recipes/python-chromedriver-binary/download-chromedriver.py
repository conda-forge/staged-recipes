import os
import sys
import subprocess

pkg_version = os.environ['PKG_VERSION']
driver_version = "{0}.{1}".format(*pkg_version.split("."))
if sys.platform == 'win32':
    chromedriver_pkg = 'chromedriver_win32.zip'
elif sys.platform == 'darwin':
    chromedriver_pkg = 'chromedriver_mac64.zip'
else:
    chromedriver_pkg = 'chromedriver_linux64.zip'


download_url = 'https://chromedriver.storage.googleapis.com/{0}/{1}'.format(driver_version, chromedriver_pkg)

subprocess.call(['curl', download_url, '-o', 'chromedriver.zip'], shell=True)
