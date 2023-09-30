import logging

import pytest

from pyinjective.async_client import AsyncClient
from pyinjective.core.network import Network
from pyinjective.proto.exchange import injective_derivative_exchange_rpc_pb2, injective_spot_exchange_rpc_pb2
from tests.rpc_fixtures.configurable_servicers import (
    ConfigurableInjectiveDerivativeExchangeRPCServicer,
    ConfigurableInjectiveSpotExchangeRPCServicer,
)
from tests.rpc_fixtures.markets_fixtures import ape_token_meta  # noqa: F401
from tests.rpc_fixtures.markets_fixtures import ape_usdt_spot_market_meta  # noqa: F401
from tests.rpc_fixtures.markets_fixtures import btc_usdt_perp_market_meta  # noqa: F401
from tests.rpc_fixtures.markets_fixtures import inj_token_meta  # noqa: F401
from tests.rpc_fixtures.markets_fixtures import inj_usdt_spot_market_meta  # noqa: F401
from tests.rpc_fixtures.markets_fixtures import usdt_perp_token_meta  # noqa: F401
from tests.rpc_fixtures.markets_fixtures import usdt_token_meta  # noqa: F401
from tests.rpc_fixtures.markets_fixtures import (  # noqa: F401; noqa: F401; noqa: F401
    first_match_bet_market_meta,
    usdt_token_meta_second_denom,
)


@pytest.fixture
def spot_servicer():
    return ConfigurableInjectiveSpotExchangeRPCServicer()


@pytest.fixture
def derivative_servicer():
    return ConfigurableInjectiveDerivativeExchangeRPCServicer()


class TestAsyncClient:
    @pytest.mark.asyncio
    async def test_sync_timeout_height_logs_exception(self, caplog):
        client = AsyncClient(
            network=Network.local(),
            insecure=False,
        )

        with caplog.at_level(logging.DEBUG):
            await client.sync_timeout_height()

        expected_log_message_prefix = "error while fetching latest block, setting timeout height to 0: "
        found_log = next(
            (record for record in caplog.record_tuples if record[2].startswith(expected_log_message_prefix)),
            None,
        )
        assert found_log is not None
        assert found_log[0] == "pyinjective.async_client.AsyncClient"
        assert found_log[1] == logging.DEBUG

    @pytest.mark.asyncio
    async def test_get_account_logs_exception(self, caplog):
        client = AsyncClient(
            network=Network.local(),
            insecure=False,
        )

        with caplog.at_level(logging.DEBUG):
            await client.get_account(address="")

        expected_log_message_prefix = "error while fetching sequence and number "
        found_log = next(
            (record for record in caplog.record_tuples if record[2].startswith(expected_log_message_prefix)),
            None,
        )
        assert found_log is not None
        assert found_log[0] == "pyinjective.async_client.AsyncClient"
        assert found_log[1] == logging.DEBUG

    @pytest.mark.asyncio
    async def test_initialize_tokens_and_markets(
        self,
        spot_servicer,
        derivative_servicer,
        inj_usdt_spot_market_meta,
        ape_usdt_spot_market_meta,
        btc_usdt_perp_market_meta,
        first_match_bet_market_meta,
    ):
        spot_servicer.markets_queue.append(
            injective_spot_exchange_rpc_pb2.MarketsResponse(
                markets=[inj_usdt_spot_market_meta, ape_usdt_spot_market_meta]
            )
        )
        derivative_servicer.markets_queue.append(
            injective_derivative_exchange_rpc_pb2.MarketsResponse(markets=[btc_usdt_perp_market_meta])
        )
        derivative_servicer.binary_option_markets_queue.append(
            injective_derivative_exchange_rpc_pb2.BinaryOptionsMarketsResponse(markets=[first_match_bet_market_meta])
        )

        client = AsyncClient(
            network=Network.local(),
            insecure=False,
        )

        client.stubSpotExchange = spot_servicer
        client.stubDerivativeExchange = derivative_servicer

        await client._initialize_tokens_and_markets()

        all_tokens = await client.all_tokens()
        assert 5 == len(all_tokens)
        inj_symbol, usdt_symbol = inj_usdt_spot_market_meta.ticker.split("/")
        ape_symbol, _ = ape_usdt_spot_market_meta.ticker.split("/")
        alternative_usdt_name = ape_usdt_spot_market_meta.quote_token_meta.name
        usdt_perp_symbol = btc_usdt_perp_market_meta.quote_token_meta.symbol
        assert inj_symbol in all_tokens
        assert usdt_symbol in all_tokens
        assert alternative_usdt_name in all_tokens
        assert ape_symbol in all_tokens
        assert usdt_perp_symbol in all_tokens

        all_spot_markets = await client.all_spot_markets()
        assert 2 == len(all_spot_markets)
        assert any((inj_usdt_spot_market_meta.market_id == market.id for market in all_spot_markets.values()))
        assert any((ape_usdt_spot_market_meta.market_id == market.id for market in all_spot_markets.values()))

        all_derivative_markets = await client.all_derivative_markets()
        assert 1 == len(all_derivative_markets)
        assert any((btc_usdt_perp_market_meta.market_id == market.id for market in all_derivative_markets.values()))

        all_binary_option_markets = await client.all_binary_option_markets()
        assert 1 == len(all_binary_option_markets)
        assert any(
            (first_match_bet_market_meta.market_id == market.id for market in all_binary_option_markets.values())
        )
