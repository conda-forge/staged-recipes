from mkdocstrings.handlers.base import CollectionError
from mkdocstrings.handlers.python import collector
import pytest

def test_init():
    """Test init for collector.PythonCollector."""
    assert collector.PythonCollector()
