try:
    from urllib.request import urlretrieve
except ImportError:
    from urllib import urlretrieve
urlretrieve('http://alps.comp-phys.org/static/software/releases/clapack.zip', 'clapack.zip')

import zipfile
with zipfile.ZipFile('clapack.zip') as fz:
    fz.extractall()