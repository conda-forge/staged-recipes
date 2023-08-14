from os import urandom

import pytest

from coincurve.utils import (
    GROUP_ORDER,
    ZERO,
    bytes_to_int,
    chunk_data,
    der_to_pem,
    get_valid_secret,
    int_to_bytes,
    int_to_bytes_padded,
    pad_scalar,
    pem_to_der,
    validate_secret,
    verify_signature,
)

from .samples import MESSAGE, PRIVATE_KEY_DER, PUBLIC_KEY_COMPRESSED, PUBLIC_KEY_UNCOMPRESSED, SIGNATURE


class TestPadScalar:
    def test_correct(self):
        assert pad_scalar(b'\x01') == b'\x00' * 31 + b'\x01'

    def test_pad_limit(self):
        n = urandom(32)
        assert len(pad_scalar(n)) == len(n)

    def test_empty_scalar(self):
        assert len(pad_scalar(b'')) == 32


def test_get_valid_secret():
    secret = get_valid_secret()
    assert len(secret) == 32 and ZERO < secret < GROUP_ORDER


class TestValidateSecret:
    def test_valid(self):
        secret = validate_secret(b'\x01')
        assert len(secret) == 32 and ZERO < secret < GROUP_ORDER

    def test_bytes_greater_than_group_order(self):
        secret = (
            b'\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff'
            b'\xff\xff\xfe\xba\xae\xdc\xe6\xafH\xa0;\xbf\xd2^\x8d'
        )
        assert secret > GROUP_ORDER

        secret = validate_secret(secret)
        assert len(secret) == 32 and ZERO < secret < GROUP_ORDER

    def test_out_of_range(self):
        with pytest.raises(ValueError):
            validate_secret(ZERO)

        with pytest.raises(ValueError):
            validate_secret(GROUP_ORDER)


def test_bytes_int_conversion():
    bytestr = b'\x00' + urandom(31)
    assert pad_scalar(int_to_bytes(bytes_to_int(bytestr))) == bytestr


def test_bytes_int_conversion_padded():
    bytestr = b'\x00' + urandom(31)
    assert int_to_bytes_padded(bytes_to_int(bytestr)) == bytestr


def test_der_conversion():
    assert pem_to_der(der_to_pem(PRIVATE_KEY_DER)) == PRIVATE_KEY_DER


def test_verify_signature():
    assert verify_signature(SIGNATURE, MESSAGE, PUBLIC_KEY_COMPRESSED)
    assert verify_signature(SIGNATURE, MESSAGE, PUBLIC_KEY_UNCOMPRESSED)


def test_chunk_data():
    assert list(chunk_data('4fadd1977328c11efc1c1d8a781aa6b9677984d3e0b', 2)) == [
        '4f',
        'ad',
        'd1',
        '97',
        '73',
        '28',
        'c1',
        '1e',
        'fc',
        '1c',
        '1d',
        '8a',
        '78',
        '1a',
        'a6',
        'b9',
        '67',
        '79',
        '84',
        'd3',
        'e0',
        'b',
    ]
