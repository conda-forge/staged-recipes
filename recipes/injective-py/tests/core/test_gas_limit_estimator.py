from decimal import Decimal

from pyinjective.composer import Composer
from pyinjective.core.gas_limit_estimator import GasLimitEstimator
from pyinjective.core.market import BinaryOptionMarket
from pyinjective.proto.cosmos.gov.v1beta1 import tx_pb2 as gov_tx_pb
from pyinjective.proto.cosmwasm.wasm.v1 import tx_pb2 as wasm_tx_pb
from pyinjective.proto.injective.exchange.v1beta1 import tx_pb2 as injective_exchange_tx_pb
from tests.model_fixtures.markets_fixtures import usdt_token  # noqa: F401


class TestGasLimitEstimator:
    def test_estimation_for_message_without_applying_rule(self):
        composer = Composer(network="testnet")
        message = composer.MsgSend(from_address="from_address", to_address="to_address", amount=1, denom="INJ")

        estimator = GasLimitEstimator.for_message(message=message)

        expected_message_gas_limit = 150_000

        assert expected_message_gas_limit == estimator.gas_limit()

    def test_estimation_for_batch_create_spot_limit_orders(self):
        spot_market_id = "0x0611780ba69656949525013d947713300f56c37b6175e02f26bffa495c3208fe"
        composer = Composer(network="testnet")
        orders = [
            composer.SpotOrder(
                market_id=spot_market_id,
                subaccount_id="subaccount_id",
                fee_recipient="fee_recipient",
                price=5,
                quantity=1,
                is_buy=True,
                is_po=False,
            ),
            composer.SpotOrder(
                market_id=spot_market_id,
                subaccount_id="subaccount_id",
                fee_recipient="fee_recipient",
                price=4,
                quantity=1,
                is_buy=True,
                is_po=False,
            ),
        ]
        message = composer.MsgBatchCreateSpotLimitOrders(sender="sender", orders=orders)
        estimator = GasLimitEstimator.for_message(message=message)

        expected_order_gas_limit = 45000
        expected_message_gas_limit = 5000

        assert (expected_order_gas_limit * 2) + expected_message_gas_limit == estimator.gas_limit()

    def test_estimation_for_batch_cancel_spot_orders(self):
        spot_market_id = "0x0611780ba69656949525013d947713300f56c37b6175e02f26bffa495c3208fe"
        composer = Composer(network="testnet")
        orders = [
            composer.OrderData(
                market_id=spot_market_id,
                subaccount_id="subaccount_id",
                order_hash="0x3870fbdd91f07d54425147b1bb96404f4f043ba6335b422a6d494d285b387f2d",
            ),
            composer.OrderData(
                market_id=spot_market_id,
                subaccount_id="subaccount_id",
                order_hash="0x222daa22f60fe9f075ed0ca583459e121c23e64431c3fbffdedda04598ede0d2",
            ),
            composer.OrderData(
                market_id=spot_market_id,
                subaccount_id="subaccount_id",
                order_hash="0x7ee76255d7ca763c56b0eab9828fca89fdd3739645501c8a80f58b62b4f76da5",
            ),
        ]
        message = composer.MsgBatchCancelSpotOrders(sender="sender", data=orders)
        estimator = GasLimitEstimator.for_message(message=message)

        expected_order_gas_limit = 45000
        expected_message_gas_limit = 5000

        assert (expected_order_gas_limit * 3) + expected_message_gas_limit == estimator.gas_limit()

    def test_estimation_for_batch_create_derivative_limit_orders(self):
        market_id = "0x17ef48032cb24375ba7c2e39f384e56433bcab20cbee9a7357e4cba2eb00abe6"
        composer = Composer(network="testnet")
        orders = [
            composer.DerivativeOrder(
                market_id=market_id,
                subaccount_id="subaccount_id",
                fee_recipient="fee_recipient",
                price=3,
                quantity=1,
                leverage=1,
                is_buy=True,
                is_po=False,
            ),
            composer.DerivativeOrder(
                market_id=market_id,
                subaccount_id="subaccount_id",
                fee_recipient="fee_recipient",
                price=20,
                quantity=1,
                leverage=1,
                is_buy=False,
                is_reduce_only=False,
            ),
        ]
        message = composer.MsgBatchCreateDerivativeLimitOrders(sender="sender", orders=orders)
        estimator = GasLimitEstimator.for_message(message=message)

        expected_order_gas_limit = 60_000
        expected_message_gas_limit = 5000

        assert (expected_order_gas_limit * 2) + expected_message_gas_limit == estimator.gas_limit()

    def test_estimation_for_batch_cancel_derivative_orders(self):
        spot_market_id = "0x0611780ba69656949525013d947713300f56c37b6175e02f26bffa495c3208fe"
        composer = Composer(network="testnet")
        orders = [
            composer.OrderData(
                market_id=spot_market_id,
                subaccount_id="subaccount_id",
                order_hash="0x3870fbdd91f07d54425147b1bb96404f4f043ba6335b422a6d494d285b387f2d",
            ),
            composer.OrderData(
                market_id=spot_market_id,
                subaccount_id="subaccount_id",
                order_hash="0x222daa22f60fe9f075ed0ca583459e121c23e64431c3fbffdedda04598ede0d2",
            ),
            composer.OrderData(
                market_id=spot_market_id,
                subaccount_id="subaccount_id",
                order_hash="0x7ee76255d7ca763c56b0eab9828fca89fdd3739645501c8a80f58b62b4f76da5",
            ),
        ]
        message = composer.MsgBatchCancelDerivativeOrders(sender="sender", data=orders)
        estimator = GasLimitEstimator.for_message(message=message)

        expected_order_gas_limit = 55_000
        expected_message_gas_limit = 5000

        assert (expected_order_gas_limit * 3) + expected_message_gas_limit == estimator.gas_limit()

    def test_estimation_for_batch_update_orders_to_create_spot_orders(self):
        market_id = "0x0611780ba69656949525013d947713300f56c37b6175e02f26bffa495c3208fe"
        composer = Composer(network="testnet")
        orders = [
            composer.SpotOrder(
                market_id=market_id,
                subaccount_id="subaccount_id",
                fee_recipient="fee_recipient",
                price=5,
                quantity=1,
                is_buy=True,
                is_po=False,
            ),
            composer.SpotOrder(
                market_id=market_id,
                subaccount_id="subaccount_id",
                fee_recipient="fee_recipient",
                price=4,
                quantity=1,
                is_buy=True,
                is_po=False,
            ),
        ]
        message = composer.MsgBatchUpdateOrders(
            sender="senders",
            derivative_orders_to_create=[],
            spot_orders_to_create=orders,
            derivative_orders_to_cancel=[],
            spot_orders_to_cancel=[],
        )
        estimator = GasLimitEstimator.for_message(message=message)

        expected_order_gas_limit = 40_000
        expected_message_gas_limit = 10_000

        assert (expected_order_gas_limit * 2) + expected_message_gas_limit == estimator.gas_limit()

    def test_estimation_for_batch_update_orders_to_create_derivative_orders(self):
        market_id = "0x17ef48032cb24375ba7c2e39f384e56433bcab20cbee9a7357e4cba2eb00abe6"
        composer = Composer(network="testnet")
        orders = [
            composer.DerivativeOrder(
                market_id=market_id,
                subaccount_id="subaccount_id",
                fee_recipient="fee_recipient",
                price=3,
                quantity=1,
                leverage=1,
                is_buy=True,
                is_po=False,
            ),
            composer.DerivativeOrder(
                market_id=market_id,
                subaccount_id="subaccount_id",
                fee_recipient="fee_recipient",
                price=20,
                quantity=1,
                leverage=1,
                is_buy=False,
                is_reduce_only=False,
            ),
        ]
        message = composer.MsgBatchUpdateOrders(
            sender="senders",
            derivative_orders_to_create=orders,
            spot_orders_to_create=[],
            derivative_orders_to_cancel=[],
            spot_orders_to_cancel=[],
        )
        estimator = GasLimitEstimator.for_message(message=message)

        expected_order_gas_limit = 60_000
        expected_message_gas_limit = 10_000

        assert (expected_order_gas_limit * 2) + expected_message_gas_limit == estimator.gas_limit()

    def test_estimation_for_batch_update_orders_to_create_binary_orders(self, usdt_token):
        market_id = "0x230dcce315364ff6360097838701b14713e2f4007d704df20ed3d81d09eec957"
        composer = Composer(network="testnet")
        market = BinaryOptionMarket(
            id=market_id,
            status="active",
            ticker="5fdbe0b1-1707800399-WAS",
            oracle_symbol="Frontrunner",
            oracle_provider="Frontrunner",
            oracle_type="provider",
            oracle_scale_factor=6,
            expiration_timestamp=1707800399,
            settlement_timestamp=1707843599,
            quote_token=usdt_token,
            maker_fee_rate=Decimal("0"),
            taker_fee_rate=Decimal("0"),
            service_provider_fee=Decimal("0.4"),
            min_price_tick_size=Decimal("10000"),
            min_quantity_tick_size=Decimal("1"),
        )
        composer.binary_option_markets[market.id] = market
        orders = [
            composer.BinaryOptionsOrder(
                market_id=market_id,
                subaccount_id="subaccount_id",
                fee_recipient="fee_recipient",
                price=3,
                quantity=1,
                leverage=1,
                is_buy=True,
                is_po=False,
            ),
            composer.BinaryOptionsOrder(
                market_id=market_id,
                subaccount_id="subaccount_id",
                fee_recipient="fee_recipient",
                price=20,
                quantity=1,
                leverage=1,
                is_buy=False,
                is_reduce_only=False,
            ),
        ]
        message = composer.MsgBatchUpdateOrders(
            sender="senders",
            derivative_orders_to_create=[],
            spot_orders_to_create=[],
            binary_options_orders_to_create=orders,
            derivative_orders_to_cancel=[],
            spot_orders_to_cancel=[],
        )
        estimator = GasLimitEstimator.for_message(message=message)

        expected_order_gas_limit = 60_000
        expected_message_gas_limit = 10_000

        assert (expected_order_gas_limit * 2) + expected_message_gas_limit == estimator.gas_limit()

    def test_estimation_for_batch_update_orders_to_cancel_spot_orders(self):
        market_id = "0x0611780ba69656949525013d947713300f56c37b6175e02f26bffa495c3208fe"
        composer = Composer(network="testnet")
        orders = [
            composer.OrderData(
                market_id=market_id,
                subaccount_id="subaccount_id",
                order_hash="0x3870fbdd91f07d54425147b1bb96404f4f043ba6335b422a6d494d285b387f2d",
            ),
            composer.OrderData(
                market_id=market_id,
                subaccount_id="subaccount_id",
                order_hash="0x222daa22f60fe9f075ed0ca583459e121c23e64431c3fbffdedda04598ede0d2",
            ),
            composer.OrderData(
                market_id=market_id,
                subaccount_id="subaccount_id",
                order_hash="0x7ee76255d7ca763c56b0eab9828fca89fdd3739645501c8a80f58b62b4f76da5",
            ),
        ]
        message = composer.MsgBatchUpdateOrders(
            sender="senders",
            derivative_orders_to_create=[],
            spot_orders_to_create=[],
            derivative_orders_to_cancel=[],
            spot_orders_to_cancel=orders,
        )
        estimator = GasLimitEstimator.for_message(message=message)

        expected_order_gas_limit = 45_000
        expected_message_gas_limit = 10_000

        assert (expected_order_gas_limit * 3) + expected_message_gas_limit == estimator.gas_limit()

    def test_estimation_for_batch_update_orders_to_cancel_derivative_orders(self):
        market_id = "0x17ef48032cb24375ba7c2e39f384e56433bcab20cbee9a7357e4cba2eb00abe6"
        composer = Composer(network="testnet")
        orders = [
            composer.OrderData(
                market_id=market_id,
                subaccount_id="subaccount_id",
                order_hash="0x3870fbdd91f07d54425147b1bb96404f4f043ba6335b422a6d494d285b387f2d",
            ),
            composer.OrderData(
                market_id=market_id,
                subaccount_id="subaccount_id",
                order_hash="0x222daa22f60fe9f075ed0ca583459e121c23e64431c3fbffdedda04598ede0d2",
            ),
            composer.OrderData(
                market_id=market_id,
                subaccount_id="subaccount_id",
                order_hash="0x7ee76255d7ca763c56b0eab9828fca89fdd3739645501c8a80f58b62b4f76da5",
            ),
        ]
        message = composer.MsgBatchUpdateOrders(
            sender="senders",
            derivative_orders_to_create=[],
            spot_orders_to_create=[],
            derivative_orders_to_cancel=orders,
            spot_orders_to_cancel=[],
        )
        estimator = GasLimitEstimator.for_message(message=message)

        expected_order_gas_limit = 55_000
        expected_message_gas_limit = 10_000

        assert (expected_order_gas_limit * 3) + expected_message_gas_limit == estimator.gas_limit()

    def test_estimation_for_batch_update_orders_to_cancel_binary_orders(self):
        market_id = "0x17ef48032cb24375ba7c2e39f384e56433bcab20cbee9a7357e4cba2eb00abe6"
        composer = Composer(network="testnet")
        orders = [
            composer.OrderData(
                market_id=market_id,
                subaccount_id="subaccount_id",
                order_hash="0x3870fbdd91f07d54425147b1bb96404f4f043ba6335b422a6d494d285b387f2d",
            ),
            composer.OrderData(
                market_id=market_id,
                subaccount_id="subaccount_id",
                order_hash="0x222daa22f60fe9f075ed0ca583459e121c23e64431c3fbffdedda04598ede0d2",
            ),
            composer.OrderData(
                market_id=market_id,
                subaccount_id="subaccount_id",
                order_hash="0x7ee76255d7ca763c56b0eab9828fca89fdd3739645501c8a80f58b62b4f76da5",
            ),
        ]
        message = composer.MsgBatchUpdateOrders(
            sender="senders",
            derivative_orders_to_create=[],
            spot_orders_to_create=[],
            derivative_orders_to_cancel=[],
            spot_orders_to_cancel=[],
            binary_options_orders_to_cancel=orders,
        )
        estimator = GasLimitEstimator.for_message(message=message)

        expected_order_gas_limit = 55_000
        expected_message_gas_limit = 10_000

        assert (expected_order_gas_limit * 3) + expected_message_gas_limit == estimator.gas_limit()

    def test_estimation_for_batch_update_orders_to_cancel_all_for_spot_market(self):
        market_id = "0x0611780ba69656949525013d947713300f56c37b6175e02f26bffa495c3208fe"
        composer = Composer(network="testnet")

        message = composer.MsgBatchUpdateOrders(
            sender="senders",
            subaccount_id="subaccount_id",
            spot_market_ids_to_cancel_all=[market_id],
            derivative_orders_to_create=[],
            spot_orders_to_create=[],
            derivative_orders_to_cancel=[],
            spot_orders_to_cancel=[],
        )
        estimator = GasLimitEstimator.for_message(message=message)

        expected_gas_limit = 35_000 * 20
        expected_message_gas_limit = 10_000

        assert expected_gas_limit + expected_message_gas_limit == estimator.gas_limit()

    def test_estimation_for_batch_update_orders_to_cancel_all_for_derivative_market(self):
        market_id = "0x0611780ba69656949525013d947713300f56c37b6175e02f26bffa495c3208fe"
        composer = Composer(network="testnet")

        message = composer.MsgBatchUpdateOrders(
            sender="senders",
            subaccount_id="subaccount_id",
            derivative_market_ids_to_cancel_all=[market_id],
            derivative_orders_to_create=[],
            spot_orders_to_create=[],
            derivative_orders_to_cancel=[],
            spot_orders_to_cancel=[],
        )
        estimator = GasLimitEstimator.for_message(message=message)

        expected_gas_limit = 45_000 * 20
        expected_message_gas_limit = 10_000

        assert expected_gas_limit + expected_message_gas_limit == estimator.gas_limit()

    def test_estimation_for_batch_update_orders_to_cancel_all_for_binary_options_market(self):
        market_id = "0x0611780ba69656949525013d947713300f56c37b6175e02f26bffa495c3208fe"
        composer = Composer(network="testnet")

        message = composer.MsgBatchUpdateOrders(
            sender="senders",
            subaccount_id="subaccount_id",
            binary_options_market_ids_to_cancel_all=[market_id],
            derivative_orders_to_create=[],
            spot_orders_to_create=[],
            derivative_orders_to_cancel=[],
            spot_orders_to_cancel=[],
        )
        estimator = GasLimitEstimator.for_message(message=message)

        expected_gas_limit = 45_000 * 20
        expected_message_gas_limit = 10_000

        assert expected_gas_limit + expected_message_gas_limit == estimator.gas_limit()

    def test_estimation_for_exec_message(self):
        market_id = "0x0611780ba69656949525013d947713300f56c37b6175e02f26bffa495c3208fe"
        composer = Composer(network="testnet")
        orders = [
            composer.SpotOrder(
                market_id=market_id,
                subaccount_id="subaccount_id",
                fee_recipient="fee_recipient",
                price=5,
                quantity=1,
                is_buy=True,
                is_po=False,
            ),
        ]
        inner_message = composer.MsgBatchUpdateOrders(
            sender="senders",
            derivative_orders_to_create=[],
            spot_orders_to_create=orders,
            derivative_orders_to_cancel=[],
            spot_orders_to_cancel=[],
        )
        message = composer.MsgExec(grantee="grantee", msgs=[inner_message])

        estimator = GasLimitEstimator.for_message(message=message)

        expected_order_gas_limit = 40_000
        expected_inner_message_gas_limit = 10_000
        expected_exec_message_gas_limit = 5_000

        assert (
            expected_order_gas_limit + expected_inner_message_gas_limit + expected_exec_message_gas_limit
            == estimator.gas_limit()
        )

    def test_estimation_for_privileged_execute_contract_message(self):
        message = injective_exchange_tx_pb.MsgPrivilegedExecuteContract()
        estimator = GasLimitEstimator.for_message(message=message)

        expected_gas_limit = 900_000

        assert expected_gas_limit == estimator.gas_limit()

    def test_estimation_for_execute_contract_message(self):
        composer = Composer(network="testnet")
        message = composer.MsgExecuteContract(
            sender="",
            contract="",
            msg="",
        )
        estimator = GasLimitEstimator.for_message(message=message)

        expected_gas_limit = 375_000

        assert expected_gas_limit == estimator.gas_limit()

    def test_estimation_for_wasm_message(self):
        message = wasm_tx_pb.MsgInstantiateContract2()
        estimator = GasLimitEstimator.for_message(message=message)

        expected_gas_limit = 225_000

        assert expected_gas_limit == estimator.gas_limit()

    def test_estimation_for_governance_message(self):
        message = gov_tx_pb.MsgDeposit()
        estimator = GasLimitEstimator.for_message(message=message)

        expected_gas_limit = 2_250_000

        assert expected_gas_limit == estimator.gas_limit()

    def test_estimation_for_generic_exchange_message(self):
        composer = Composer(network="testnet")
        message = composer.MsgCreateSpotLimitOrder(
            sender="sender",
            market_id="0x0611780ba69656949525013d947713300f56c37b6175e02f26bffa495c3208fe",
            subaccount_id="subaccount_id",
            fee_recipient="fee_recipient",
            price=7.523,
            quantity=0.01,
            is_buy=True,
            is_po=False,
        )
        estimator = GasLimitEstimator.for_message(message=message)

        expected_gas_limit = 100_000

        assert expected_gas_limit == estimator.gas_limit()
