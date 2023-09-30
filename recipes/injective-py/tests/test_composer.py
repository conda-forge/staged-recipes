from decimal import Decimal

import pytest

from pyinjective.composer import Composer
from pyinjective.constant import Denom
from pyinjective.core.market import BinaryOptionMarket, DerivativeMarket, SpotMarket
from pyinjective.core.network import Network
from pyinjective.proto.injective.exchange.v1beta1 import exchange_pb2
from tests.model_fixtures.markets_fixtures import btc_usdt_perp_market  # noqa: F401
from tests.model_fixtures.markets_fixtures import first_match_bet_market  # noqa: F401
from tests.model_fixtures.markets_fixtures import inj_token  # noqa: F401
from tests.model_fixtures.markets_fixtures import inj_usdt_spot_market  # noqa: F401
from tests.model_fixtures.markets_fixtures import usdt_perp_token  # noqa: F401
from tests.model_fixtures.markets_fixtures import usdt_token  # noqa: F401


class TestComposer:
    @pytest.fixture
    def inj_usdt_market_id(self):
        return "0xa508cb32923323679f29a032c70342c147c17d0145625922b0ef22e955c844c0"

    @pytest.fixture
    def basic_composer(self, inj_usdt_spot_market, btc_usdt_perp_market, first_match_bet_market):
        composer = Composer(
            network=Network.devnet().string(),
            spot_markets={inj_usdt_spot_market.id: inj_usdt_spot_market},
            derivative_markets={btc_usdt_perp_market.id: btc_usdt_perp_market},
            binary_option_markets={first_match_bet_market.id: first_match_bet_market},
            tokens={
                inj_usdt_spot_market.base_token.symbol: inj_usdt_spot_market.base_token,
                inj_usdt_spot_market.quote_token.symbol: inj_usdt_spot_market.quote_token,
                btc_usdt_perp_market.quote_token.symbol: btc_usdt_perp_market.quote_token,
            },
        )

        return composer

    def test_composer_initialization_from_ini_files(self):
        composer = Composer(network=Network.devnet().string())

        inj_token = composer.tokens["INJ"]
        inj_usdt_spot_market = next(
            (market for market in composer.spot_markets.values() if market.ticker == "'Devnet Spot INJ/USDT'")
        )
        inj_usdt_perp_market = next(
            (
                market
                for market in composer.derivative_markets.values()
                if market.ticker == "'Devnet Derivative INJ/USDT PERP'"
            )
        )

        assert 18 == inj_token.decimals
        assert 18 == inj_usdt_spot_market.base_token.decimals
        assert 6 == inj_usdt_spot_market.quote_token.decimals
        assert 6 == inj_usdt_perp_market.quote_token.decimals

    def test_buy_spot_order_creation(self, basic_composer: Composer, inj_usdt_spot_market: SpotMarket):
        fee_recipient = "inj1hkhdaj2a2clmq5jq6mspsggqs32vynpk228q3r"
        price = 6.869
        quantity = 1587
        order = basic_composer.SpotOrder(
            market_id=inj_usdt_spot_market.id,
            subaccount_id="1",
            fee_recipient=fee_recipient,
            price=price,
            quantity=quantity,
            is_buy=True,
        )

        price_decimals = inj_usdt_spot_market.quote_token.decimals - inj_usdt_spot_market.base_token.decimals
        chain_format_price = Decimal(str(price)) * Decimal(f"1e{price_decimals}")
        expected_price = (
            (chain_format_price // inj_usdt_spot_market.min_price_tick_size)
            * inj_usdt_spot_market.min_price_tick_size
            * Decimal("1e18")
        )
        chain_format_quantity = Decimal(str(quantity)) * Decimal(f"1e{inj_usdt_spot_market.base_token.decimals}")
        expected_quantity = (
            (chain_format_quantity // inj_usdt_spot_market.min_quantity_tick_size)
            * inj_usdt_spot_market.min_quantity_tick_size
            * Decimal("1e18")
        )

        assert order.market_id == inj_usdt_spot_market.id
        assert order.order_info.subaccount_id == "1"
        assert order.order_info.fee_recipient == fee_recipient
        assert order.order_info.price == str(int(expected_price))
        assert order.order_info.quantity == str(int(expected_quantity))
        assert order.order_type == exchange_pb2.OrderType.BUY
        assert order.trigger_price == "0"

    def test_buy_derivative_order_creation(self, basic_composer: Composer, btc_usdt_perp_market: DerivativeMarket):
        fee_recipient = "inj1hkhdaj2a2clmq5jq6mspsggqs32vynpk228q3r"
        price = 6.869
        quantity = 1587
        leverage = 2
        order = basic_composer.DerivativeOrder(
            market_id=btc_usdt_perp_market.id,
            subaccount_id="1",
            fee_recipient=fee_recipient,
            price=price,
            quantity=quantity,
            is_buy=True,
            leverage=leverage,
        )

        price_decimals = btc_usdt_perp_market.quote_token.decimals
        chain_format_price = Decimal(str(price)) * Decimal(f"1e{price_decimals}")
        expected_price = (
            (chain_format_price // btc_usdt_perp_market.min_price_tick_size)
            * btc_usdt_perp_market.min_price_tick_size
            * Decimal("1e18")
        )
        chain_format_quantity = Decimal(str(quantity))
        expected_quantity = (
            (chain_format_quantity // btc_usdt_perp_market.min_quantity_tick_size)
            * btc_usdt_perp_market.min_quantity_tick_size
            * Decimal("1e18")
        )
        chain_format_margin = (chain_format_quantity * chain_format_price) / Decimal(leverage)
        expected_margin = (
            (chain_format_margin // btc_usdt_perp_market.min_quantity_tick_size)
            * btc_usdt_perp_market.min_quantity_tick_size
            * Decimal("1e18")
        )

        assert order.market_id == btc_usdt_perp_market.id
        assert order.order_info.subaccount_id == "1"
        assert order.order_info.fee_recipient == fee_recipient
        assert order.order_info.price == str(int(expected_price))
        assert order.order_info.quantity == str(int(expected_quantity))
        assert order.order_type == exchange_pb2.OrderType.BUY
        assert order.margin == str(int(expected_margin))
        assert order.trigger_price == "0"

    def test_increase_position_margin(self, basic_composer: Composer, btc_usdt_perp_market: DerivativeMarket):
        sender = "inj1hkhdaj2a2clmq5jq6mspsggqs32vynpk228q3r"
        amount = 1587.789
        message = basic_composer.MsgIncreasePositionMargin(
            sender=sender,
            source_subaccount_id="1",
            destination_subaccount_id="2",
            market_id=btc_usdt_perp_market.id,
            amount=amount,
        )

        price_decimals = btc_usdt_perp_market.quote_token.decimals
        chain_format_margin = Decimal(str(amount)) * Decimal(f"1e{price_decimals}")
        expected_margin = (
            (chain_format_margin // btc_usdt_perp_market.min_quantity_tick_size)
            * btc_usdt_perp_market.min_quantity_tick_size
            * Decimal("1e18")
        )

        assert message.market_id == btc_usdt_perp_market.id
        assert message.sender == sender
        assert message.source_subaccount_id == "1"
        assert message.destination_subaccount_id == "2"
        assert message.amount == str(int(expected_margin))

    def test_buy_binary_option_order_creation_with_fixed_denom(
        self, basic_composer: Composer, first_match_bet_market: BinaryOptionMarket
    ):
        fee_recipient = "inj1hkhdaj2a2clmq5jq6mspsggqs32vynpk228q3r"
        price = 6.869
        quantity = 1587
        fixed_denom = Denom(
            description="Fixed denom",
            base=2,
            quote=6,
            min_price_tick_size=1000,
            min_quantity_tick_size=10000,
        )

        order = basic_composer.BinaryOptionsOrder(
            market_id=first_match_bet_market.id,
            subaccount_id="1",
            fee_recipient=fee_recipient,
            price=price,
            quantity=quantity,
            is_buy=True,
            denom=fixed_denom,
        )

        price_decimals = fixed_denom.quote
        chain_format_price = Decimal(str(price)) * Decimal(f"1e{price_decimals}")
        expected_price = (
            (chain_format_price // Decimal(str(fixed_denom.min_price_tick_size)))
            * Decimal(str(fixed_denom.min_price_tick_size))
            * Decimal("1e18")
        )
        quantity_decimals = fixed_denom.base
        chain_format_quantity = Decimal(str(quantity)) * Decimal(f"1e{quantity_decimals}")
        expected_quantity = (
            (chain_format_quantity // Decimal(str(fixed_denom.min_quantity_tick_size)))
            * Decimal(str(fixed_denom.min_quantity_tick_size))
            * Decimal("1e18")
        )
        chain_format_margin = chain_format_quantity * chain_format_price
        expected_margin = (
            (chain_format_margin // Decimal(str(fixed_denom.min_quantity_tick_size)))
            * Decimal(str(fixed_denom.min_quantity_tick_size))
            * Decimal("1e18")
        )

        assert order.market_id == first_match_bet_market.id
        assert order.order_info.subaccount_id == "1"
        assert order.order_info.fee_recipient == fee_recipient
        assert order.order_info.price == str(int(expected_price))
        assert order.order_info.quantity == str(int(expected_quantity))
        assert order.order_type == exchange_pb2.OrderType.BUY
        assert order.margin == str(int(expected_margin))
        assert order.trigger_price == "0"

    def test_buy_binary_option_order_creation_without_fixed_denom(
        self,
        basic_composer: Composer,
        first_match_bet_market: BinaryOptionMarket,
    ):
        fee_recipient = "inj1hkhdaj2a2clmq5jq6mspsggqs32vynpk228q3r"
        price = 6.869
        quantity = 1587

        order = basic_composer.BinaryOptionsOrder(
            market_id=first_match_bet_market.id,
            subaccount_id="1",
            fee_recipient=fee_recipient,
            price=price,
            quantity=quantity,
            is_buy=True,
        )

        price_decimals = first_match_bet_market.quote_token.decimals
        chain_format_price = Decimal(str(price)) * Decimal(f"1e{price_decimals}")
        expected_price = (
            (chain_format_price // first_match_bet_market.min_price_tick_size)
            * first_match_bet_market.min_price_tick_size
            * Decimal("1e18")
        )
        chain_format_quantity = Decimal(str(quantity))
        expected_quantity = (
            (chain_format_quantity // first_match_bet_market.min_quantity_tick_size)
            * first_match_bet_market.min_quantity_tick_size
            * Decimal("1e18")
        )
        chain_format_margin = chain_format_quantity * chain_format_price
        expected_margin = (
            (chain_format_margin // first_match_bet_market.min_quantity_tick_size)
            * first_match_bet_market.min_quantity_tick_size
            * Decimal("1e18")
        )

        assert order.market_id == first_match_bet_market.id
        assert order.order_info.subaccount_id == "1"
        assert order.order_info.fee_recipient == fee_recipient
        assert order.order_info.price == str(int(expected_price))
        assert order.order_info.quantity == str(int(expected_quantity))
        assert order.order_type == exchange_pb2.OrderType.BUY
        assert order.margin == str(int(expected_margin))
        assert order.trigger_price == "0"
