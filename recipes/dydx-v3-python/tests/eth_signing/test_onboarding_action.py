from web3 import Web3

from dydx3.constants import NETWORK_ID_MAINNET
from dydx3.constants import OFF_CHAIN_ONBOARDING_ACTION
from dydx3.eth_signing import SignWithWeb3
from dydx3.eth_signing import SignWithKey
from dydx3.eth_signing import SignOnboardingAction

GANACHE_ADDRESS = '0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1'
GANACHE_PRIVATE_KEY = (
    '0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d'
)

EXPECTED_SIGNATURE = (
    '0x0a30eea502e9805b95bd432fa1952e345dda3e9f72f7732aa00775865352e2b549'
    '29803c221e9e63861e4604fbc796a4e1a6ca23d49452338a3d7602aaf6d1841c00'
)


class TestOnboardingAction():

    def test_sign_via_local_node(self):
        web3 = Web3()  # Connect to a local Ethereum node.
        signer = SignWithWeb3(web3)

        action_signer = SignOnboardingAction(signer, NETWORK_ID_MAINNET)
        signature = action_signer.sign(
            GANACHE_ADDRESS,
            action=OFF_CHAIN_ONBOARDING_ACTION,
        )
        assert action_signer.verify(
            signature,
            GANACHE_ADDRESS,
            action=OFF_CHAIN_ONBOARDING_ACTION,
        )
        assert signature == EXPECTED_SIGNATURE

    def test_sign_via_account(self):
        web3 = Web3(None)
        web3_account = web3.eth.account.create()
        signer = SignWithKey(web3_account.key)

        action_signer = SignOnboardingAction(signer, NETWORK_ID_MAINNET)
        signature = action_signer.sign(
            signer.address,
            action=OFF_CHAIN_ONBOARDING_ACTION,
        )
        assert action_signer.verify(
            signature,
            signer.address,
            action=OFF_CHAIN_ONBOARDING_ACTION,
        )

    def test_sign_via_private_key(self):
        signer = SignWithKey(GANACHE_PRIVATE_KEY)

        action_signer = SignOnboardingAction(signer, NETWORK_ID_MAINNET)
        signature = action_signer.sign(
            GANACHE_ADDRESS,
            action=OFF_CHAIN_ONBOARDING_ACTION,
        )
        assert action_signer.verify(
            signature,
            GANACHE_ADDRESS,
            action=OFF_CHAIN_ONBOARDING_ACTION,
        )
        assert signature == EXPECTED_SIGNATURE
