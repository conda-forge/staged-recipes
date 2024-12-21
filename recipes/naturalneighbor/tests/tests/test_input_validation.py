import pytest
import numpy as np

from naturalneighbor import griddata


def test_invalid_known_points_shape():
    num_points = 5
    num_dimensions = 3
    bad_third_dim = 2
    known_points = np.random.rand(num_points, num_dimensions, bad_third_dim)
    known_values = np.random.rand(num_points)
    interp_ranges = [
        [0, 1, 1],
        [0, 1, 1],
        [0, 1, 1],
    ]

    with pytest.raises(ValueError):
        griddata(known_points, known_values, interp_ranges)


def test_different_num_points_and_values():
    num_points = 5
    num_dimensions = 3
    known_points = np.random.rand(num_points, num_dimensions)
    known_values = np.random.rand(num_points + 1)
    interp_ranges = [
        [0, 1, 1],
        [0, 1, 1],
        [0, 1, 1],
    ]

    with pytest.raises(ValueError):
        griddata(known_points, known_values, interp_ranges)


def test_zero_step_size():
    num_points = 5
    num_dimensions = 3
    known_points = np.random.rand(num_points, num_dimensions)
    known_values = np.random.rand(num_points)
    interp_ranges = [
        [0, 1, 0],
        [0, 1, 1],
        [0, 1, 1],
    ]

    with pytest.raises(ValueError):
        griddata(known_points, known_values, interp_ranges)


def test_negative_step_size():
    num_points = 5
    num_dimensions = 3
    known_points = np.random.rand(num_points, num_dimensions)
    known_values = np.random.rand(num_points)
    interp_ranges = [
        [0, 1, -1],
        [0, 1, 1],
        [0, 1, 1],
    ]

    with pytest.raises(ValueError):
        griddata(known_points, known_values, interp_ranges)


def test_step_before_stop():
    num_points = 5
    num_dimensions = 3
    known_points = np.random.rand(num_points, num_dimensions)
    known_values = np.random.rand(num_points)
    interp_ranges = [
        [2, 1, 1],
        [0, 1, 1],
        [0, 1, 1],
    ]

    with pytest.raises(ValueError):
        griddata(known_points, known_values, interp_ranges)


def test_zero_length_complex_step():
    num_points = 5
    num_dimensions = 3
    known_points = np.random.rand(num_points, num_dimensions)
    known_values = np.random.rand(num_points)
    interp_ranges = [
        [2, 1, 1],
        [0, 1, 1],
        [0, 1, 0j],
    ]

    with pytest.raises(ValueError):
        griddata(known_points, known_values, interp_ranges)
