import sys
import os.path

from pytest import main

import kwant

def test():
    kwant_path = os.path.dirname(os.path.abspath(kwant.__file__))
    sys.exit(main([kwant_path, "-x", "-v"]))

test()
