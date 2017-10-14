import MDAnalysis as mda
import pytim
from pytim.datafiles import WATER_GRO
u = mda.Universe(WATER_GRO)
inter = pytim.ITIM(u)
