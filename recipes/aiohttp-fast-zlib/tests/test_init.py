import zlib as zlib_original
from unittest.mock import patch

import aiohttp.compression_utils
import aiohttp.http_websocket
import pytest

import aiohttp_fast_zlib

try:
    from isal import (
        isal_zlib as expected_zlib,
    )
except ImportError:
    from zlib_ng import zlib_ng as expected_zlib


@pytest.mark.skipif(
    aiohttp_fast_zlib._AIOHTTP_VERSION >= (3, 11),
    reason="Only works with aiohttp less than 3.11+",
)
def test_enable_disable_pre_311():
    """Test enable/disable."""
    assert aiohttp.http_websocket.zlib is zlib_original
    aiohttp_fast_zlib.enable()
    assert aiohttp.http_websocket.zlib is expected_zlib
    aiohttp_fast_zlib.disable()
    assert aiohttp.http_websocket.zlib is zlib_original
    aiohttp_fast_zlib.enable()
    assert aiohttp.http_websocket.zlib is expected_zlib
    aiohttp_fast_zlib.disable()


@pytest.mark.skipif(
    aiohttp_fast_zlib._AIOHTTP_VERSION < (3, 11)
    or aiohttp_fast_zlib._AIOHTTP_VERSION >= (3, 12),
    reason="Only works with aiohttp 3.11.x",
)
def test_enable_disable_311():
    """Test enable/disable for aiohttp 3.11.x."""
    from aiohttp._websocket import writer

    assert writer.zlib is zlib_original
    aiohttp_fast_zlib.enable()
    assert writer.zlib is expected_zlib
    aiohttp_fast_zlib.disable()
    assert writer.zlib is zlib_original
    aiohttp_fast_zlib.enable()
    assert writer.zlib is expected_zlib
    aiohttp_fast_zlib.disable()


@pytest.mark.skipif(
    aiohttp_fast_zlib._AIOHTTP_VERSION < (3, 11)
    or aiohttp_fast_zlib._AIOHTTP_VERSION >= (3, 12),
    reason="Only works with aiohttp 3.11.x",
)
def test_enable_disable_when_all_missing_311():
    """Test enable/disable for aiohttp 3.11.x when all fast libs are missing."""
    from aiohttp._websocket import writer

    with patch.object(aiohttp_fast_zlib, "best_zlib", zlib_original):
        assert writer.zlib is zlib_original
        aiohttp_fast_zlib.enable()
        assert writer.zlib is zlib_original
        aiohttp_fast_zlib.disable()
        assert writer.zlib is zlib_original
        aiohttp_fast_zlib.enable()
        assert writer.zlib is zlib_original
        aiohttp_fast_zlib.disable()
        assert writer.zlib is zlib_original


@pytest.mark.skipif(
    aiohttp_fast_zlib._AIOHTTP_VERSION >= (3, 11),
    reason="Only works with aiohttp less than 3.11+",
)
def test_enable_disable_when_all_missing_pre_311():
    """Test enable/disable."""
    with patch.object(aiohttp_fast_zlib, "best_zlib", zlib_original):
        assert aiohttp.http_websocket.zlib is zlib_original
        aiohttp_fast_zlib.enable()
        assert aiohttp.http_websocket.zlib is zlib_original
        aiohttp_fast_zlib.disable()
        assert aiohttp.http_websocket.zlib is zlib_original
        aiohttp_fast_zlib.enable()
        assert aiohttp.http_websocket.zlib is zlib_original
        aiohttp_fast_zlib.disable()
        assert aiohttp.http_websocket.zlib is zlib_original


@pytest.mark.skipif(
    aiohttp_fast_zlib._AIOHTTP_VERSION >= (3, 12),
    reason="Only works with aiohttp < 3.12",
)
def test_enable_disable_when_all_missing():
    """Test enable/disable when all fast libs are missing."""
    with patch.object(aiohttp_fast_zlib, "best_zlib", zlib_original):
        assert aiohttp.compression_utils.zlib is zlib_original
        aiohttp_fast_zlib.enable()
        assert aiohttp.compression_utils.zlib is zlib_original
        aiohttp_fast_zlib.disable()
        assert aiohttp.compression_utils.zlib is zlib_original
        aiohttp_fast_zlib.enable()
        assert aiohttp.compression_utils.zlib is zlib_original
        aiohttp_fast_zlib.disable()
        assert aiohttp.compression_utils.zlib is zlib_original


@pytest.mark.skipif(
    aiohttp_fast_zlib._AIOHTTP_VERSION < (3, 12),
    reason="Only works with aiohttp >= 3.12",
)
def test_enable_disable_312_plus():
    """Test enable/disable for aiohttp 3.12+ with native set_zlib_backend."""
    from aiohttp.compression_utils import ZLibBackend

    # Test enable
    aiohttp_fast_zlib.enable()
    assert ZLibBackend._zlib_backend is expected_zlib

    # Test disable
    aiohttp_fast_zlib.disable()
    assert ZLibBackend._zlib_backend is zlib_original

    # Test enable again
    aiohttp_fast_zlib.enable()
    assert ZLibBackend._zlib_backend is expected_zlib

    # Clean up
    aiohttp_fast_zlib.disable()
    assert ZLibBackend._zlib_backend is zlib_original


@pytest.mark.skipif(
    aiohttp_fast_zlib._AIOHTTP_VERSION < (3, 12),
    reason="Only works with aiohttp >= 3.12",
)
def test_enable_disable_when_all_missing_312_plus():
    """Test enable/disable for aiohttp 3.12+ when all fast libs are missing."""
    from aiohttp.compression_utils import ZLibBackend

    # Store the original backend
    original_backend = ZLibBackend._zlib_backend

    with patch.object(aiohttp_fast_zlib, "best_zlib", zlib_original):
        # Test enable - should not change backend when best_zlib is zlib_original
        aiohttp_fast_zlib.enable()
        assert ZLibBackend._zlib_backend is original_backend

        # Test disable - should not change backend either
        aiohttp_fast_zlib.disable()
        assert ZLibBackend._zlib_backend is original_backend
