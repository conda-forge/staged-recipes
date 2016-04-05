import nose
import sys

print("sys.platform = ", sys.platform)
print("sys.version = ", sys.version)

if sys.platform.startswith('win'):
    print("!!! Skipping Tests")
    print("!!! There are known failures in pyamg 3.0.2 on windows")
    print("!!! See https://github.com/pyamg/pyamg/issues/168")
elif sys.platform == 'darwin' and sys.version.startswith('2.7'):
    print("!!! Skipping Tests")
    print("!!! There are known failures in pyamg 3.0.2 on Python 2.7 / OSX")
    print("!!! See https://github.com/pyamg/pyamg/issues/165")
else:
    config = nose.config.Config(verbosity=2)
    nose.runmodule('pyamg', config=config)
