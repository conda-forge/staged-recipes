import os
import sys

if sys.platform == 'win32':
    wrappers_dir = os.path.expandvars('$PREFIX/Scripts/wrappers/conda')
    ext = '.bat'
else:
    wrappers_dir = os.path.expandvars('$PREFIX/bin/wrappers/conda')
    ext = ''

assert os.path.isdir(wrappers_dir)
assert os.path.isfile(os.path.join(wrappers_dir, 'python' + ext))
