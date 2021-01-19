import tempfile
from os.path import isfile, join
import requests
from pymol2 import SingletonPyMOL


PDB_ID = "1aki"
CIF_PATH = join(tempfile.gettempdir(), PDB_ID+".cif")
PNG_PATH = join(tempfile.gettempdir(), "pymol_test.png")


r = requests.get(f"https://files.rcsb.org/download/{PDB_ID}.cif")
with open(CIF_PATH, "w") as file:
    file.write(r.text)


pymol = SingletonPyMOL()
pymol.start()
cmd = pymol.cmd

cmd.load(CIF_PATH)
cmd.png(PNG_PATH, ray=1)

assert isfile(PNG_PATH)