import sys
from numba.cuda.cudadrv.libs import test

sys.exit(0 if test() else 1)

