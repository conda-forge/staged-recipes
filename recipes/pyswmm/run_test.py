import sys
import pyswmm
from pyswmm.lib import DLL_SELECTION

assert sys.prefix.replace('\\', '/') in DLL_SELECTION()
