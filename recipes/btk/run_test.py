"""
Minimal addaption of the original test suite in BTK 
so it can run on conda-forge's build system.
"""

import sys
import os
import unittest
import subprocess
from pathlib import Path

tdd_filepathin = Path("BTKData/Input/").absolute()
tdd_filepathout = Path("output/").absolute()

with open("_TDDConfigure.py", "w+") as fh:
   fh.write(f"""
TDD_FilePathIN = r'{tdd_filepathin}/'
TDD_FilePathOUT = r'{tdd_filepathout}/'

C3DFilePathIN = TDD_FilePathIN + 'C3DSamples/'
C3DFilePathOUT = TDD_FilePathOUT + 'C3DSamples/'
TRCFilePathIN = TDD_FilePathIN + 'TRCSamples/'
TRCFilePathOUT = TDD_FilePathOUT + 'TRCSamples/'
""")


# Checkout test data used in later testing
subprocess.run(["git", "clone", "--quiet", "https://github.com/Biomechanical-ToolKit/BTKData.git", "BTKData"])  
subprocess.run(["git", "-C", "BTKData", "checkout", "-B", "testdata", "777b5987"])  

for fn in os.listdir("BTKData/Input"):
    os.makedirs(Path("output") / fn, exist_ok=True)


sys.path.append('testing/python') # All of the unit tests
sys.path.append('.') # _TDDConfigure.py

import _TDDCommon
import _TDDIO
import _TDDBasicFilters

if __name__ == '__main__':
    out = True
    result = unittest.TextTestRunner().run(_TDDCommon.suite())
    out &= result.wasSuccessful()
    result = unittest.TextTestRunner().run(_TDDIO.suite())
    out &= result.wasSuccessful()
    result = unittest.TextTestRunner().run(_TDDBasicFilters.suite())
    out &= result.wasSuccessful()
            
    if out:
        sys.exit(0)
    else:
        sys.exit(1)
