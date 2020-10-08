import sys
import os
from numba.cuda.cudadrv.libs import test, get_cudalib
from numba.cuda.cudadrv.nvvm import NVVM


def run_test():
    # on windows only nvvm is available to numba
    if sys.platform.startswith('win'):
        nvvm = NVVM()
        print("NVVM version", nvvm.get_version())
        return nvvm.get_version() is not None
    if not test():
        return False
    nvvm = NVVM()
    print("NVVM version", nvvm.get_version())
    # check pkg version matches lib pulled in
    gotlib = get_cudalib('cublas')
    # check cufft b/c cublas has an incorrect version in 10.1 update 1
    gotlib = get_cudalib('cufft')
    return bool(get_cudalib('cublas')) and bool(get_cudalib('cufft'))


sys.exit(0 if run_test() else 1)
