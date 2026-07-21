"""Smoke test for the satkit conda recipe.

Verifies that with satkit-data installed as a run-dep, the JPL
ephemeris is discoverable and a Moon position query returns a value of
the right magnitude (~3.84e8 m).
"""

import numpy as np

import satkit


def main() -> None:
    t = satkit.time.from_date(2024, 3, 1)
    r = satkit.jplephem.geocentric_pos(satkit.solarsystem.Moon, t)
    d = float(np.linalg.norm(r))
    assert 3.0e8 < d < 5.0e8, f"unexpected Moon distance: {d}"
    print(f"moon distance OK: {d:.0f} m")


if __name__ == "__main__":
    main()
