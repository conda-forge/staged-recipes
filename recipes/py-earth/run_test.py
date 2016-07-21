import pyearth
import nose
import os

pyearth_dir = os.path.dirname(
    os.path.abspath(pyearth.__file__))
os.chdir(pyearth_dir)
nose.run(module=pyearth)
