import psiresp
import numpy as np

mol = psiresp.Molecule(qcmol={
    "symbols": ["H", "H"],
    "geometry": [0, 0, -3, 0, 0, 3],
    "connectivity": [[0, 1, 1]],
})
mol.generate_conformers()
mol.generate_orientations()
orientation = mol.conformers[0].orientations[0]
orientation.grid = np.arange(12).reshape((4, 3))
orientation.esp = np.arange(4)
job = psiresp.Job(molecules=[mol])
job.compute_charges()
