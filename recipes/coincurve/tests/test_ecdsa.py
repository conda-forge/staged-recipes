from coincurve.ecdsa import cdata_to_der, der_to_cdata

from .samples import SIGNATURE


def test_der():
    assert cdata_to_der(der_to_cdata(SIGNATURE)) == SIGNATURE
