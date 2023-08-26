from web3 import Web3

from dydx3.constants import NETWORK_ID_MAINNET
from dydx3.eth_signing import SignWithWeb3
from dydx3.eth_signing import SignWithKey
from dydx3.eth_signing import SignEthPrivateAction

GANACHE_ADDRESS = '0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1'
GANACHE_PRIVATE_KEY = (
    '0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d'
)
PARAMS = {
    'method': 'POST',
    'request_path': 'v3/test',
    'body': '{}',
    'timestamp': '2021-01-08T10:06:12.500Z',
}

EXPECTED_SIGNATURE = (
    '0x3ec5317783b313b0acac1f13a23eaaa2fca1f45c2f395081e9bfc20b4cc1acb17e'
    '3d755764f37bf13fa62565c9cb50475e0a987ab0afa74efde0b3926bb7ab9d1b00'
)


class TestApiKeyAction():

    def test_sign_via_local_node(self):
        web3 = Web3()  # Connect to a local Ethereum node.
        signer = SignWithWeb3(web3)

        action_signer = SignEthPrivateAction(signer, NETWORK_ID_MAINNET)
        signature = action_signer.sign(GANACHE_ADDRESS, **PARAMS)
        assert action_signer.verify(
            signature,
            GANACHE_ADDRESS,
            **PARAMS,
        )
        assert signature == EXPECTED_SIGNATURE

    def test_sign_via_account(self):
        web3 = Web3(None)
        web3_account = web3.eth.account.create()
        signer = SignWithKey(web3_account.key)

        action_signer = SignEthPrivateAction(signer, NETWORK_ID_MAINNET)
        signature = action_signer.sign(signer.address, **PARAMS)
        assert action_signer.verify(
            signature,
            signer.address,
            **PARAMS,
        )

    def test_sign_via_private_key(self):
        signer = SignWithKey(GANACHE_PRIVATE_KEY)

        action_signer = SignEthPrivateAction(signer, NETWORK_ID_MAINNET)
        signature = action_signer.sign(GANACHE_ADDRESS, **PARAMS)
        assert action_signer.verify(
            signature,
            GANACHE_ADDRESS,
            **PARAMS,
        )
        assert signature == EXPECTED_SIGNATURE
