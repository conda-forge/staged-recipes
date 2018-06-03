import twisted
import os

print('twisted.__version__: %s' % twisted.__version__)
assert twisted.__version__ == os.getenv("PKG_VERSION")
