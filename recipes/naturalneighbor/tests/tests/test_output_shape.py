import numpy as np

from naturalneighbor import griddata


def test_output_shape():
    num_points = 5
    num_dimensions = 3
    known_points = np.random.rand(num_points, num_dimensions)
    known_values = np.random.rand(num_points)
    interp_ranges = [
        [0, 2, 1],
        [0, 1.5, 0.5],
        [0, 1, 2],
    ]

    interp_values = griddata(known_points, known_values, interp_ranges)
    assert interp_values.shape == (2, 3, 1)
