import os
import sys
try:                 # Python 3
    import urllib.request as urllib
except ImportError:  # Python 2
    import urllib


pkg_version = os.environ['PKG_VERSION']
driver_version = "{0}.{1}".format(*pkg_version.split("."))
if sys.platform == 'win32':
    chromedriver_pkg = 'chromedriver_win32.zip'
elif sys.platform == 'darwin':
    chromedriver_pkg = 'chromedriver_mac64.zip'
else:
    chromedriver_pkg = 'chromedriver_linux64.zip'


download_url = 'https://chromedriver.storage.googleapis.com/{0}/{1}'.format(driver_version, chromedriver_pkg)

resp = urllib.urlopen(download_url)
with open('chromedriver.zip', 'wb') as zip_file:
    zip_file.write(resp.read())
