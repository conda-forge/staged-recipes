"""Typeguard support for tests."""
import pytest

try:
    import typeguard  # noqa: F401
except ImportError:
    has_typeguard = False
else:
    has_typeguard = True


skip_if_typeguard = pytest.mark.skipif(
    has_typeguard,
    reason="Broken if Typeguard is enabled",
)
