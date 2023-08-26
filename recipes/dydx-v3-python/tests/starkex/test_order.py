from dydx3.constants import MARKET_ETH_USD
from dydx3.constants import NETWORK_ID_GOERLI
from dydx3.constants import ORDER_SIDE_BUY
from dydx3.helpers.request_helpers import iso_to_epoch_seconds
from dydx3.starkex.order import SignableOrder

# Test data where the public key y-coordinate is odd.
MOCK_PUBLIC_KEY = (
    '3b865a18323b8d147a12c556bfb1d502516c325b1477a23ba6c77af31f020fd'
)
MOCK_PRIVATE_KEY = (
    '58c7d5a90b1776bde86ebac077e053ed85b0f7164f53b080304a531947f46e3'
)
MOCK_SIGNATURE = (
    '07670488d9d2c6ff980ca86e6d05b89414de0f2bfd462a1058fb05add68d034a' +
    '036268ae33e8e21d324e975678f56b66dacb2502a7de1512a46b96fc0e106f79'
)

# Test data where the public key y-coordinate is even.
MOCK_PUBLIC_KEY_EVEN_Y = (
    '5c749cd4c44bdc730bc90af9bfbdede9deb2c1c96c05806ce1bc1cb4fed64f7'
)
MOCK_SIGNATURE_EVEN_Y = (
    '0618bcd2a8a027cf407116f88f2fa0d866154ee421cdf8a9deca0fecfda5277b' +
    '03e42fa1d039522fc77c23906253e537cc5b2f392dba6f2dbb35d51cbe37273a'
)

# Mock order params.
ORDER_PARAMS = {
    "network_id": NETWORK_ID_GOERLI,
    "market": MARKET_ETH_USD,
    "side": ORDER_SIDE_BUY,
    "position_id": 12345,
    "human_size": '145.0005',
    "human_price": '350.00067',
    "limit_fee": '0.125',
    "client_id": (
        'This is an ID that the client came up with ' +
        'to describe this order'
    ),
    "expiration_epoch_seconds": iso_to_epoch_seconds(
        '2020-09-17T04:15:55.028Z',
    ),
}


class TestOrder():

    def test_sign_order(self):
        order = SignableOrder(**ORDER_PARAMS)
        signature = order.sign(MOCK_PRIVATE_KEY)
        assert signature == MOCK_SIGNATURE

    def test_verify_signature_odd_y(self):
        order = SignableOrder(**ORDER_PARAMS)
        assert order.verify_signature(MOCK_SIGNATURE, MOCK_PUBLIC_KEY)

    def test_verify_signature_even_y(self):
        order = SignableOrder(**ORDER_PARAMS)
        assert order.verify_signature(
            MOCK_SIGNATURE_EVEN_Y,
            MOCK_PUBLIC_KEY_EVEN_Y,
        )

    def test_starkware_representation(self):
        order = SignableOrder(**ORDER_PARAMS)
        starkware_order = order.to_starkware()
        assert starkware_order.quantums_amount_synthetic == 145000500000
        assert starkware_order.quantums_amount_collateral == 50750272151
        assert starkware_order.quantums_amount_fee == 6343784019

        # Order expiration should be rounded up and should have a buffer added.
        assert starkware_order.expiration_epoch_hours == 444701

    def test_convert_order_fee_edge_case(self):
        order = SignableOrder(
            **dict(
                ORDER_PARAMS,
                limit_fee='0.000001999999999999999999999999999999999999999999',
            ),
        )
        starkware_order = order.to_starkware()
        assert starkware_order.quantums_amount_fee == 50751

    def test_order_expiration_boundary_case(self):
        order = SignableOrder(
            **dict(
                ORDER_PARAMS,
                expiration_epoch_seconds=iso_to_epoch_seconds(
                    # Less than one second after the start of the hour.
                    '2021-02-24T16:00:00.407Z',
                ),
            ),
        )
        assert order.to_starkware().expiration_epoch_hours == 448553
