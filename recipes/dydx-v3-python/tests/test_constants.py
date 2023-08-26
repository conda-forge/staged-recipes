from dydx3.constants import (
    SYNTHETIC_ASSET_MAP,
    SYNTHETIC_ASSET_ID_MAP,
    ASSET_RESOLUTION,
    COLLATERAL_ASSET,
)


class TestConstants():
    def test_constants_have_regular_structure(self):
        for market, asset in SYNTHETIC_ASSET_MAP.items():
            market_parts = market.split('-')
            base_token, quote_token = market_parts
            assert base_token == asset
            assert quote_token == 'USD'
            assert len(market_parts) == 2

        assert list(SYNTHETIC_ASSET_MAP.values()) \
            == list(SYNTHETIC_ASSET_ID_MAP.keys())

        assets = [x for x in ASSET_RESOLUTION.keys() if x != COLLATERAL_ASSET]
        assert assets == list(SYNTHETIC_ASSET_MAP.values())
