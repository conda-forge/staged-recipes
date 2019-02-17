import os.path
from pytest import main
import qsymm

def test():
    qsymm_path = os.path.dirname(os.path.abspath(qsymm.__file__))
    return main([qsymm_path, "-x", "-v"])

test()
