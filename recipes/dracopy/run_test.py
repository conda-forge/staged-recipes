import numpy as np
import DracoPy


points = np.array(
    [[0, 0, 0], [1, 0, 0], [0, 1, 0], [0, 0, 1]],
    dtype=np.float32,
)
faces = np.array([[0, 1, 2], [0, 1, 3]], dtype=np.uint32)

encoded_cloud = DracoPy.encode(
    points,
    compression_level=1,
    quantization_bits=14,
    preserve_order=True,
)
cloud = DracoPy.decode(encoded_cloud)
np.testing.assert_allclose(cloud.points, points)

encoded_mesh = DracoPy.encode(
    points,
    faces,
    compression_level=1,
    quantization_bits=14,
)
mesh = DracoPy.decode(encoded_mesh)
assert mesh.faces.shape == (2, 3)
assert mesh.points.shape[1] == 3
