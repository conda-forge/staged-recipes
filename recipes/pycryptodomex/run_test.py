import os
import re
import psutil
import platform

libname = re.escape(os.environ['CONDA_PREFIX']) + '.*(libgmp.*.(dylib|so)|(mpir|gmp).*.dll)'

# The import below will fail if we don't have gmp/mpir
from Cryptodome.Math import _Numbers_gmp as NumbersGMP

# Make sure that gmp/mpir is indeed loaded in memory
p = psutil.Process(os.getpid())
assert any(bool(re.match(libname, x.path)) for x in p.memory_maps())
