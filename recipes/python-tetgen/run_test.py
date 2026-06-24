import numpy as np

import tetgen
from tetgen._tetgen import PyTetgen


POINTS = np.array(
    [
        [0.0, 0.0, 0.0],
        [1.0, 0.0, 0.0],
        [1.0, 1.0, 0.0],
        [0.0, 1.0, 0.0],
        [0.0, 0.0, 1.0],
        [1.0, 0.0, 1.0],
        [1.0, 1.0, 1.0],
        [0.0, 1.0, 1.0],
    ],
    dtype=np.float64,
)

FACES = np.array(
    [
        [0, 1, 2],
        [2, 3, 0],
        [0, 1, 5],
        [5, 4, 0],
        [1, 2, 6],
        [6, 5, 1],
        [2, 3, 7],
        [7, 6, 2],
        [3, 0, 4],
        [4, 7, 3],
        [4, 5, 6],
        [6, 7, 4],
    ],
    dtype=np.int32,
)


def _check_tets(nodes, elems):
    assert nodes.ndim == 2
    assert nodes.shape[1] == 3
    assert elems.ndim == 2
    assert elems.shape[1] == 4
    assert np.isfinite(nodes).all()
    assert elems.min() >= 0
    assert elems.max() < nodes.shape[0]


core = PyTetgen()
core.load_mesh(POINTS, FACES)
core.tetrahedralize()
_check_tets(core.return_nodes(), core.return_tets())

tgen = tetgen.TetGen(POINTS, FACES)
nodes, elems, *_ = tgen.tetrahedralize(switches="pq1.1/10YQ")
_check_tets(nodes, elems)
