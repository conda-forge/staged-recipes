import pytest


@pytest.fixture
def inj_token_meta():
    from pyinjective.proto.exchange.injective_spot_exchange_rpc_pb2 import TokenMeta

    token = TokenMeta(
        name="Injective Protocol",
        address="0xe28b3B32B6c345A34Ff64674606124Dd5Aceca30",
        symbol="INJ",
        logo="https://static.alchemyapi.io/images/assets/7226.png",
        decimals=18,
        updated_at=1681739137644,
    )

    return token


@pytest.fixture
def ape_token_meta():
    from pyinjective.proto.exchange.injective_spot_exchange_rpc_pb2 import TokenMeta

    token = TokenMeta(
        name="APE",
        address="0x0000000000000000000000000000000000000000",
        symbol="APE",
        logo="https://assets.coingecko.com/coins/images/24383/small/apecoin.jpg?1647476455",
        decimals=18,
        updated_at=1681739137646,
    )

    return token


@pytest.fixture
def usdt_token_meta():
    from pyinjective.proto.exchange.injective_spot_exchange_rpc_pb2 import TokenMeta

    token = TokenMeta(
        name="USDT",
        address="0x0000000000000000000000000000000000000000",
        symbol="USDT",
        logo="https://static.alchemyapi.io/images/assets/825.png",
        decimals=6,
        updated_at=1681739137645,
    )

    return token


@pytest.fixture
def usdt_token_meta_second_denom():
    from pyinjective.proto.exchange.injective_spot_exchange_rpc_pb2 import TokenMeta

    token = TokenMeta(
        name="USDT Second Denom",
        address="0x0000000000000000000000000000000000000000",
        symbol="USDT",
        logo="https://static.alchemyapi.io/images/assets/826.png",
        decimals=6,
        updated_at=1691739137645,
    )

    return token


@pytest.fixture
def usdt_perp_token_meta():
    from pyinjective.proto.exchange.injective_derivative_exchange_rpc_pb2 import TokenMeta

    token = TokenMeta(
        name="Tether",
        address="0xdAC17F958D2ee523a2206206994597C13D831ec7",
        symbol="USDTPerp",
        logo="https://static.alchemyapi.io/images/assets/825.png",
        decimals=6,
        updated_at=1683929869866,
    )

    return token


@pytest.fixture
def ape_usdt_spot_market_meta(ape_token_meta, usdt_token_meta_second_denom):
    from pyinjective.proto.exchange.injective_spot_exchange_rpc_pb2 import SpotMarketInfo

    market = SpotMarketInfo(
        market_id="0x8b67e705bb4e09c88aecfc295569481dbf2fe1d5efe364651fbe72385938e000",
        market_status="active",
        ticker="APE/USDT",
        base_denom="peggy0x44C21afAaF20c270EBbF5914Cfc3b5022173FEB7",
        base_token_meta=ape_token_meta,
        quote_denom="factory/peggy0x87aB3B4C8661e07D6372361211B96ed4Dc300000",
        quote_token_meta=usdt_token_meta_second_denom,
        maker_fee_rate="-0.0001",
        taker_fee_rate="0.001",
        service_provider_fee="0.4",
        min_price_tick_size="0.000000000000001",
        min_quantity_tick_size="1000000000000000",
    )

    return market


@pytest.fixture
def inj_usdt_spot_market_meta(inj_token_meta, usdt_token_meta):
    from pyinjective.proto.exchange.injective_spot_exchange_rpc_pb2 import SpotMarketInfo

    market = SpotMarketInfo(
        market_id="0x7a57e705bb4e09c88aecfc295569481dbf2fe1d5efe364651fbe72385938e9b0",
        market_status="active",
        ticker="INJ/USDT",
        base_denom="peggy0x44C21afAaF20c270EBbF5914Cfc3b5022173FEB7",
        base_token_meta=inj_token_meta,
        quote_denom="peggy0x87aB3B4C8661e07D6372361211B96ed4Dc36B1B5",
        quote_token_meta=usdt_token_meta,
        maker_fee_rate="-0.0001",
        taker_fee_rate="0.001",
        service_provider_fee="0.4",
        min_price_tick_size="0.000000000000001",
        min_quantity_tick_size="1000000000000000",
    )

    return market


@pytest.fixture
def btc_usdt_perp_market_meta(usdt_perp_token_meta):
    from pyinjective.proto.exchange.injective_derivative_exchange_rpc_pb2 import (
        DerivativeMarketInfo,
        PerpetualMarketFunding,
        PerpetualMarketInfo,
    )

    perpetual_market_info = PerpetualMarketInfo(
        hourly_funding_rate_cap="0.0000625",
        hourly_interest_rate="0.00000416666",
        next_funding_timestamp=1684764000,
        funding_interval=3600,
    )
    perpetual_market_funding = PerpetualMarketFunding(
        cumulative_funding="6880500093.266083891331674194",
        cumulative_price="-0.952642601240470199",
        last_timestamp=1684763442,
    )

    market = DerivativeMarketInfo(
        market_id="0x4ca0f92fc28be0c9761326016b5a1a2177dd6375558365116b5bdda9abc229ce",
        market_status="active",
        ticker="BTC/USDT PERP",
        oracle_base="BTC",
        oracle_quote="USDT",
        oracle_type="bandibc",
        oracle_scale_factor=6,
        initial_margin_ratio="0.095",
        maintenance_margin_ratio="0.025",
        quote_denom="peggy0xdAC17F958D2ee523a2206206994597C13D831ec7",
        quote_token_meta=usdt_perp_token_meta,
        maker_fee_rate="-0.0001",
        taker_fee_rate="0.001",
        service_provider_fee="0.4",
        is_perpetual=True,
        min_price_tick_size="1000000",
        min_quantity_tick_size="0.0001",
        perpetual_market_info=perpetual_market_info,
        perpetual_market_funding=perpetual_market_funding,
    )

    return market


@pytest.fixture
def first_match_bet_market_meta(inj_usdt_spot_market_meta):
    from pyinjective.proto.exchange.injective_derivative_exchange_rpc_pb2 import BinaryOptionsMarketInfo

    market = BinaryOptionsMarketInfo(
        market_id="0x230dcce315364ff6360097838701b14713e2f4007d704df20ed3d81d09eec957",
        market_status="active",
        ticker="5fdbe0b1-1707800399-WAS",
        oracle_symbol="Frontrunner",
        oracle_provider="Frontrunner",
        oracle_type="provider",
        oracle_scale_factor=6,
        expiration_timestamp=1707800399,
        settlement_timestamp=1707843599,
        quote_denom=inj_usdt_spot_market_meta.quote_denom,
        maker_fee_rate="0",
        taker_fee_rate="0",
        service_provider_fee="0.4",
        min_price_tick_size="10000",
        min_quantity_tick_size="1",
    )

    return market
