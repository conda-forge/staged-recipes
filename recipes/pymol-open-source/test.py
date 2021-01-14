import tempfile
from os.path import isfile, join
from pymol2 import SingletonPyMOL

PNG_NAME = join(tempfile.gettempdir(), "pymol_test.png")

pymol = SingletonPyMOL()
pymol.start()
cmd = pymol.cmd

cmd.load("1aki.cif")
cmd.png(PNG_NAME, ray=1)

assert isfile(PNG_NAME)