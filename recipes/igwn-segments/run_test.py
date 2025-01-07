# Copyright Cardiff University 2024-

"""Sanity tests for igwn-segments.
"""

import sys

import pytest

from igwn_segments import segment


def test_segment():
    a = segment(1, 2)
    b = segment(2, 3)
    c = segment(5, 6)
    assert a.connects(b)
    assert a in (a + b)
    assert (a + b).intersects(b)
    assert a.disjoint(c)


if __name__ == "__main__":
    sys.exit(pytest.main(["-v"]))
