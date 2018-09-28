import numpy as np
import coord

# test soem basic functions
theta1 = 12 * coord.degrees
theta2 = (12 + 360) * coord.degrees
assert np.allclose(theta2.wrap().rad, theta1.rad)

# make sure the C++ stuff works by calling it
sincos = theta1.sincos()
assert np.allclose(
    sincos,
    [np.sin(12.0 / 180.0 * np.pi), np.cos(12.0 / 180.0 * np.pi)])
