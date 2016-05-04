import sys
import numpy
import numexpr
import numexpr.interpreter

from multiprocessing import freeze_support

if __name__ == "__main__":
    freeze_support()
    numexpr.test()
