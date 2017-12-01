import os
import re
import psutil
import platform

libname = r'(libgmp.*.(dylib|so)|(mpir|gmp).*.dll)'

if platform.system() == 'Darwin':
    # ctypes.util.find_library() isn't CONDA_PREFIX aware :'(
    # https://github.com/ContinuumIO/anaconda-issues/issues/1716
    os.environ['DYLD_FALLBACK_LIBRARY_PATH'] = os.path.join(os.environ['CONDA_PREFIX'], 'lib')

# The import below will fail if we don't have gmp/mpir
from Cryptodome.Math import _Numbers_gmp as NumbersGMP

# Make sure that gmp/mpir is indeed loaded in memory
p = psutil.Process(os.getpid())
assert any(bool(re.match(libname, os.path.basename(x.path))) for x in p.memory_maps())
