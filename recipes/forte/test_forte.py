"""
test_input_example_1:
   Run a FCI computation on methylene using ROHF orbitals optimized for the 3B1 state.
   Computes the lowest 3B1 state and the lowest two 1A1 states.
"""

import math
import psi4
import forte

ref_e_3b1 = -38.924726774489
ref_e_1a1 = -38.866616413802
ref_e_1a1_ex = -38.800424868719

psi4.geometry("""
0 3
C
H 1 1.085
H 1 1.085 2 135.5
""")

forte.clean_options()

psi4.set_options(
    {
        'basis': 'DZ',
        'scf_type': 'pk',
        'e_convergence': 12,
        'reference': 'rohf',
        'forte__active_space_solver': 'fci',
        'forte__restricted_docc': [1, 0, 0, 0],
        'forte__active': [3, 0, 2, 2],
        'forte__multiplicity': 3,
        'forte__root_sym': 2,
    }
)
efci = psi4.energy('forte')
assert math.isclose(ref_e_3b1, efci, abs_tol=1e-9)

psi4.set_options(
    {
        'forte__active_space_solver': 'fci',
        'forte__restricted_docc': [1, 0, 0, 0],
        'forte__active': [3, 0, 2, 2],
        'forte__multiplicity': 1,
        'forte__root_sym': 0,
        'forte__nroot': 2
    }
)

efci = psi4.energy('forte')
assert math.isclose(ref_e_1a1, efci, abs_tol=1e-9)

psi4.set_options(
    {
        'forte__active_space_solver': 'fci',
        'forte__restricted_docc': [1, 0, 0, 0],
        'forte__active': [3, 0, 2, 2],
        'forte__multiplicity': 1,
        'forte__root_sym': 0,
        'forte__nroot': 2,
        'forte__root': 1
    }
)

efci = psi4.energy('forte')
assert math.isclose(ref_e_1a1_ex, efci, abs_tol=1e-9)

