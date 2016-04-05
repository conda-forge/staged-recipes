import nose
import sys

print(sys.platform)
print(sys.version)

if sys.platform == 'darwin' and sys.version.startswith('2.7'):
    print("There are known errors in pyamg 3.0.2 on Python 2.7 / OSX")
    print("skipping tests; see https://github.com/pyamg/pyamg/issues/165")
else:
    config = nose.config.Config(verbosity=2)
    nose.runmodule('pyamg', config=config)
