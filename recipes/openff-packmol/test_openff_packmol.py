from openff.toolkit import Molecule, Quantity
from openff.packmol import pack_box, solvate_topology


ethanol = Molecule.from_smiles("CCO")
water = Molecule.from_smiles("O")

pack_box(
    molecules = [ethanol, water, ethanol,],
    number_of_copies = [1, 3, 1],
    solute=None,
    box_vectors=Quantity([3, 4, 5,], "nanometer")
)
