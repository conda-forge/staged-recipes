import pytest
from eth_account.messages import ValidationError

from .conftest import (
    InvalidMessageMissingDomainFields,
    MessageWithCanonicalDomainFieldOrder,
    MessageWithNonCanonicalDomainFieldOrder,
)


def test_multilevel_message(valid_message_with_name_domain_field):
    msg = valid_message_with_name_domain_field.signable_message
    assert msg.version.hex() == "0x01"
    assert msg.header.hex() == "0x336a9d2b32d1ab7ea7bbbd2565eca1910e54b74843858dec7a81f772a3c17e17"
    assert msg.body.hex() == "0x306af87567fa87e55d2bd925d9a3ed2b1ec2c3e71b142785c053dc60b6ca177b"


def test_invalid_message_without_domain_fields():
    with pytest.raises(ValidationError):
        InvalidMessageMissingDomainFields(value=1)


def test_yearn_vaults_message(permit, permit_raw_data):
    """
    Testing a real world EIP712 message for a "permit" call in yearn-vaults.
    """

    assert permit._body_ == permit_raw_data


def test_eip712_domain_field_order_is_invariant():
    assert (
        MessageWithCanonicalDomainFieldOrder._domain_
        == MessageWithNonCanonicalDomainFieldOrder._domain_
    )


def test_ux_tuple_and_starargs(permit, Permit):
    assert tuple(Permit(*permit)) == tuple(permit)
