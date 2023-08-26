from web3 import Web3

from dydx3 import Client
from dydx3.constants import NETWORK_ID_MAINNET
from dydx3.constants import NETWORK_ID_GOERLI

from tests.constants import DEFAULT_HOST

GANACHE_PRIVATE_KEY = (
    '0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d'
)

EXPECTED_API_KEY_CREDENTIALS_MAINNET = {
    'key': '50fdcaa0-62b8-e827-02e8-a9520d46cb9f',
    'secret': 'rdHdKDAOCa0B_Mq-Q9kh8Fz6rK3ocZNOhKB4QsR9',
    'passphrase': '12_1LuuJMZUxcj3kGBWc',
}
EXPECTED_STARK_KEY_PAIR_WITH_Y_COORDINATE_MAINNET = {
    'public_key':
        '0x39d88860b99b1809a63add01f7dfa59676ae006bbcdf38ff30b6a69dcf55ed3',
    'public_key_y_coordinate':
        '0x2bdd58a2c2acb241070bc5d55659a85bba65211890a8c47019a33902aba8400',
    'private_key':
        '0x170d807cafe3d8b5758f3f698331d292bf5aeb71f6fd282f0831dee094ee891',
}
EXPECTED_API_KEY_CREDENTIALS_GOERLI = {
    'key': '1871d1ba-537c-7fe8-743c-172bcd4ae5c6',
    'secret': 'tQxclqFWip0HL4Q-xkwZb_lTfOQz4GD5CHHpYzWa',
    'passphrase': 'B8JFepDVn8eixnor7Imv',
}
EXPECTED_STARK_KEY_PAIR_WITH_Y_COORDINATE_GOERLI = {
    'public_key':
        '0x3ea05770b452df14427b3f07ff600faa132ecc3d7643275042cb4da6ad99972',
    'public_key_y_coordinate':
        '0x7310e2ab01978806a6fb6e51a9ee1c9a5c5117c63530ad7dead2b9f72094cc3',
    'private_key':
        '0x1019187d91b8effe153ab1932930e27c8d01c56ad9cc937c777633c0ffc5a7e'
}


class TestOnboarding():

    def test_derive_stark_key_on_mainnet_from_web3(self):
        web3 = Web3()  # Connect to a local Ethereum node.
        client = Client(
            host=DEFAULT_HOST,
            network_id=NETWORK_ID_MAINNET,
            web3=web3,
        )
        signer_address = web3.eth.accounts[0]
        stark_key_pair_with_y_coordinate = client.onboarding.derive_stark_key(
            signer_address,
        )
        assert stark_key_pair_with_y_coordinate == \
            EXPECTED_STARK_KEY_PAIR_WITH_Y_COORDINATE_MAINNET

    def test_recover_default_api_key_credentials_on_mainnet_from_web3(self):
        web3 = Web3()  # Connect to a local Ethereum node.
        client = Client(
            host=DEFAULT_HOST,
            network_id=NETWORK_ID_MAINNET,
            web3=web3,
        )
        signer_address = web3.eth.accounts[0]
        api_key_credentials = (
            client.onboarding.recover_default_api_key_credentials(
                signer_address,
            )
        )
        assert api_key_credentials == EXPECTED_API_KEY_CREDENTIALS_MAINNET

    def test_derive_stark_key_on_GOERLI_from_web3(self):
        web3 = Web3()  # Connect to a local Ethereum node.
        client = Client(
            host=DEFAULT_HOST,
            network_id=NETWORK_ID_GOERLI,
            web3=web3,
        )
        signer_address = web3.eth.accounts[0]
        stark_key_pair_with_y_coordinate = client.onboarding.derive_stark_key(
            signer_address,
        )
        assert stark_key_pair_with_y_coordinate == \
            EXPECTED_STARK_KEY_PAIR_WITH_Y_COORDINATE_GOERLI

    def test_recover_default_api_key_credentials_on_GOERLI_from_web3(self):
        web3 = Web3()  # Connect to a local Ethereum node.
        client = Client(
            host=DEFAULT_HOST,
            network_id=NETWORK_ID_GOERLI,
            web3=web3,
        )
        signer_address = web3.eth.accounts[0]
        api_key_credentials = (
            client.onboarding.recover_default_api_key_credentials(
                signer_address,
            )
        )
        assert api_key_credentials == EXPECTED_API_KEY_CREDENTIALS_GOERLI

    def test_derive_stark_key_on_mainnet_from_priv(self):
        client = Client(
            host=DEFAULT_HOST,
            network_id=NETWORK_ID_MAINNET,
            eth_private_key=GANACHE_PRIVATE_KEY,
            api_key_credentials={'key': 'value'},
        )
        signer_address = client.default_address
        stark_key_pair_with_y_coordinate = client.onboarding.derive_stark_key(
            signer_address,
        )
        assert stark_key_pair_with_y_coordinate == \
            EXPECTED_STARK_KEY_PAIR_WITH_Y_COORDINATE_MAINNET

    def test_recover_default_api_key_credentials_on_mainnet_from_priv(self):
        client = Client(
            host=DEFAULT_HOST,
            network_id=NETWORK_ID_MAINNET,
            eth_private_key=GANACHE_PRIVATE_KEY,
        )
        signer_address = client.default_address
        api_key_credentials = (
            client.onboarding.recover_default_api_key_credentials(
                signer_address,
            )
        )
        assert api_key_credentials == EXPECTED_API_KEY_CREDENTIALS_MAINNET

    def test_derive_stark_key_on_GOERLI_from_priv(self):
        client = Client(
            host=DEFAULT_HOST,
            network_id=NETWORK_ID_GOERLI,
            eth_private_key=GANACHE_PRIVATE_KEY,
        )
        signer_address = client.default_address
        stark_key_pair_with_y_coordinate = client.onboarding.derive_stark_key(
            signer_address,
        )
        assert stark_key_pair_with_y_coordinate == \
            EXPECTED_STARK_KEY_PAIR_WITH_Y_COORDINATE_GOERLI

    def test_recover_default_api_key_credentials_on_GOERLI_from_priv(self):
        client = Client(
            host=DEFAULT_HOST,
            network_id=NETWORK_ID_GOERLI,
            eth_private_key=GANACHE_PRIVATE_KEY,
        )
        signer_address = client.default_address
        api_key_credentials = (
            client.onboarding.recover_default_api_key_credentials(
                signer_address,
            )
        )
        assert api_key_credentials == EXPECTED_API_KEY_CREDENTIALS_GOERLI
