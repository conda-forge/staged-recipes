import os

path = os.path.join(os.environ['PREFIX'], 'lib', 'emscripten-' + os.environ['PKG_VERSION'], '.emscripten')
with open(path, 'r') as fi:
    s = fi.read()

s = s.replace("BINARYEN_ROOT = os.path.expanduser(os.getenv('BINARYEN', '')) # directory",
              "BINARYEN_ROOT = os.path.expanduser(os.getenv('BINARYEN', '{}')) # directory".format(os.environ['PREFIX']))

with open(path, 'w') as fo:
    fo.write(s)