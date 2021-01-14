from pymol2 import SingletonPyMOL
import os
from os.path import isfile, join

PNG_NAME = join(os.sep, "tmp", "pymol_test.png")

pymol = SingletonPyMOL()
pymol.start()
cmd = pymol.cmd

cmd.load("1aki.cif")
cmd.png(PNG_NAME, ray=1)

assert isfile(PNG_NAME)