import numpy as np
from pygel3d import hmesh


vertices = np.array(
    [
        [0.0, 0.0, 0.0],
        [1.0, 0.0, 0.0],
        [0.0, 1.0, 0.0],
        [0.0, 0.0, 1.0],
    ],
    dtype=np.float64,
)
faces = np.array(
    [
        [0, 2, 1],
        [0, 1, 3],
        [1, 2, 3],
        [2, 0, 3],
    ],
    dtype=np.int32,
)

mesh = hmesh.Manifold.from_triangles(vertices, faces)
assert hmesh.valid(mesh)
assert hmesh.closed(mesh)
assert mesh.no_allocated_vertices() == 4
assert mesh.no_allocated_faces() == 4
assert hmesh.area(mesh) > 0
