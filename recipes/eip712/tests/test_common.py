import pytest
from eth_account.messages import hash_eip712_message as hash_message

from eip712.common import SAFE_VERSIONS, create_safe_tx_def

MSIG_ADDRESS = "0xFEB4acf3df3cDEA7399794D0869ef76A6EfAff52"


@pytest.mark.parametrize("version", SAFE_VERSIONS)
def test_gnosis_safe_tx(version):
    tx_def = create_safe_tx_def(
        version=version,
        contract_address=MSIG_ADDRESS,
        chain_id=1,
    )

    msg = tx_def(to=MSIG_ADDRESS, nonce=0)

    assert msg.signable_message.header.hex() == (
        "0x88fbc465dedd7fe71b7baef26a1f46cdaadd50b95c77cbe88569195a9fe589ab"
        if version in ("1.3.0",)
        else "0x590e9c66b22ee4584cd655fda57748ce186b85f829a092c28209478efbe86a92"
    )

    assert hash_message(msg).hex() == (
        "3c2fdf2ea8af328a67825162e7686000787c5cc9f4b27cb6bfbcaa445b59e2c4"
        if version in ("1.3.0",)
        else "1b393826bed1f2297ffc01916f8339892f9a51dc7f35f477b9a5cdd651d28603"
    )
