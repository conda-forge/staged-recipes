"""Offline smoke test for the satkit conda package.

conda-forge test environments may have no network access, and the JPL
ephemeris is deliberately NOT downloaded here. With the core data compiled
into the extension (IERS nutation tables, gravity models), the following
must work with an *empty* data directory and downloads forbidden:
time scales, frame transforms, gravity, SGP4, Kepler, Lambert.
"""

import os
import tempfile

import numpy as np

# Forbid downloads and point the data directory at an empty temp dir BEFORE
# importing satkit, so nothing on the build host can leak in.
_tmp = tempfile.mkdtemp(prefix="satkit-conda-test-")
os.environ["SATKIT_OFFLINE"] = "1"
os.environ["SATKIT_DATA"] = _tmp

import satkit as sk  # noqa: E402


def main() -> None:
    assert sk.utils.is_offline(), "SATKIT_OFFLINE=1 must put satkit in offline mode"
    assert sk.utils.datadir() == _tmp, sk.utils.datadir()

    # Time scales (compiled-in leap-second table)
    t = sk.time(2024, 3, 1, 0, 0, 0)
    assert abs((t.as_mjd(sk.timescale.TAI) - t.as_mjd(sk.timescale.UTC)) * 86400 - 37.0) < 1e-6

    # Gravity for every built-in model (embedded coefficient files)
    pos = np.array([7000e3, 0.0, 0.0])
    for model in (sk.gravmodel.egm96, sk.gravmodel.jgm3, sk.gravmodel.jgm2, sk.gravmodel.itugrace16):
        a = sk.gravity(pos, model=model, degree=20)
        assert abs(np.linalg.norm(a) - 8.13) < 0.1, (model, a)

    # Precession-nutation (embedded IERS tables 5.2a/b/d)
    q = sk.frametransform.rotation(sk.frame.CIRS, sk.frame.GCRF, t)
    assert 1e-4 < q.angle < 1e-2, q.angle

    # SGP4 from a TLE (ISS)
    tles = sk.TLE.from_lines(
        [
            "ISS (ZARYA)",
            "1 25544U 98067A   24061.50000000  .00016717  00000-0  30306-3 0  9991",
            "2 25544  51.6400 208.9163 0006703  35.6100 324.5200 15.49560000439123",
        ]
    )
    tle = tles[0] if isinstance(tles, list) else tles
    p, v = sk.sgp4(tle, tle.epoch)
    assert 6.6e6 < np.linalg.norm(p) < 6.9e6, p

    # The ephemeris must NOT be fetched. On a clean conda test environment
    # there is no ephemeris anywhere, so the query fails with the offline
    # error; on a developer machine another search directory may already hold
    # one and the query succeeds. Either way the empty write directory must
    # stay empty — that is the proof that offline mode blocked the download.
    try:
        sk.jplephem.geocentric_pos(sk.solarsystem.Moon, t)
    except RuntimeError as e:
        assert "SATKIT_OFFLINE" in str(e) or "offline" in str(e).lower(), e
        print("ephemeris query correctly refused offline:", str(e).splitlines()[0][:100])
    else:
        print("note: an ephemeris was found in another search directory on this host")
    assert not os.listdir(_tmp), f"offline mode must not write into the data directory: {os.listdir(_tmp)}"

    print("satkit offline smoke test OK (no data directory, no network)")


if __name__ == "__main__":
    main()
