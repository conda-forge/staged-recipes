import pytest

try:
    snap_compare()
except AttributeError:
    raise AttributeError