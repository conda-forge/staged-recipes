"""M3C2 on two synthetic surfaces 5 cm apart: distances and level of detection."""
import numpy as np

import py4dgeo

rng = np.random.default_rng(42)


def surface(n=40_000, offset=0.0, noise=0.002):
    xy = rng.uniform(-1, 1, (n, 2))
    z = 0.1 * np.sin(3 * xy[:, 0]) * np.cos(2 * xy[:, 1]) + offset
    return np.column_stack([xy, z + rng.normal(0, noise, n)])


earlier, later = py4dgeo.Epoch(surface()), py4dgeo.Epoch(surface(offset=0.05))
corepoints = earlier.cloud[::200]
distances, uncertainties = py4dgeo.M3C2(
    epochs=(earlier, later), corepoints=corepoints, cyl_radius=0.05,
    normal_radii=(0.1,), max_distance=0.5,
).run()
ok = np.isfinite(distances)
assert ok.mean() > 0.9, ok.mean()
# the surfaces moved 5 cm along z; M3C2 measures along the normal (mostly z)
assert abs(np.median(np.abs(distances[ok])) - 0.05) < 0.005, np.median(distances[ok])
lod = uncertainties["lodetection"][ok]
assert np.all(lod > 0) and np.median(lod) < 0.01, np.median(lod)
# the same surface twice: no change
distances, _ = py4dgeo.M3C2(
    epochs=(earlier, earlier), corepoints=corepoints, cyl_radius=0.05, normal_radii=(0.1,),
).run()
assert np.allclose(distances[np.isfinite(distances)], 0)
print("M3C2 OK")

# an epoch saved by the PyPI wheel (py4dgeo 1.2.1) after build_kdtree(): its saved KD-tree
# (nanoflann's own format) must load and answer like a tree built here
epoch = py4dgeo.load_epoch("epoch_pypi_1.2.1.zip")
assert epoch.kdtree.leaf_parameter() == 10, epoch.kdtree.leaf_parameter()
query = np.array([0.5, 0.5, 0.5])
found = np.sort(epoch.kdtree.radius_search(query, 0.2))
expected = np.flatnonzero(np.linalg.norm(epoch.cloud - query, axis=1) < 0.2)
assert np.array_equal(found, expected), (found, expected)
print("PyPI epoch archive OK")
