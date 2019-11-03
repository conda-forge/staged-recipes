import sys
import os

for kv in os.environ.items():
    print('%s=%r' % kv)

print('CWD:', os.getcwd())
print('sys.prefix:', sys.prefix)
print('Pointer size:', tuple.__itemsize__)

from distutils.core import setup
from distutils.extension import Extension

# compile the spammodule using distutils
sys.argv[1:] = ['build_ext', '--inplace', '--verbose']
setup(name="spam", ext_modules=[Extension("spam", ["spam.c"])])

# test module just generated
import spam

assert spam.sqr(7) == 49

# Cleanup spam.o
try:
    os.remove("spam.o")
except:
    pass
