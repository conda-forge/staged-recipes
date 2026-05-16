import numpy as np
import pysplashsurf


def test_marching_cubes_sphere():
    radius = 1.0
    num_verts = 24
    grid_size = radius * 2.2
    dx = grid_size / (num_verts - 1)
    translation = -0.5 * grid_size

    coords = np.arange(num_verts, dtype=np.float64) * dx + translation
    x, y, z = np.meshgrid(coords, coords, coords, indexing="ij")
    sdf = np.sqrt(x**2 + y**2 + z**2) - radius

    mesh, grid = pysplashsurf.marching_cubes(
        sdf,
        iso_surface_threshold=0.0,
        cube_size=dx,
        translation=[translation] * 3,
        return_grid=True,
    )

    assert len(mesh.vertices) > 0
    norms = np.linalg.norm(mesh.vertices, axis=1)
    assert norms.min() > radius - 3e-3
    assert norms.max() < radius + 3e-3
    assert pysplashsurf.check_mesh_consistency(mesh, grid) is None


test_marching_cubes_sphere()
