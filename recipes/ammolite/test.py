import numpy as np
import biotite.structure.io.mmtf as mmtf
import biotite.database.rcsb as rcsb
import ammolite


PDB_ID = "1l2y"


mmtf_file = mmtf.MMTFFile.read(rcsb.fetch(PDB_ID, "mmtf"))
ref_structure = mmtf.get_structure(mmtf_file, include_bonds=True)

pymol_object = ammolite.PyMOLObject.from_structure(ref_structure)
test_structure = pymol_object.to_structure(include_bonds=True)

for cat in ref_structure.get_annotation_categories():
    assert (
        test_structure.get_annotation(cat) == ref_structure.get_annotation(cat)
    ).all()
assert np.allclose(test_structure.coord, ref_structure.coord)
assert test_structure.bonds == ref_structure.bonds
