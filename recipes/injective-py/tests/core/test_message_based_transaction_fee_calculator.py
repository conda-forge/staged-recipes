import math
from decimal import Decimal

import pytest

from pyinjective import Transaction
from pyinjective.async_client import AsyncClient
from pyinjective.composer import Composer
from pyinjective.core.broadcaster import MessageBasedTransactionFeeCalculator
from pyinjective.core.network import Network
from pyinjective.proto.cosmos.gov.v1beta1 import tx_pb2 as gov_tx_pb2
from pyinjective.proto.cosmwasm.wasm.v1 import tx_pb2 as wasm_tx_pb2
from pyinjective.proto.injective.exchange.v1beta1 import tx_pb2


class TestMessageBasedTransactionFeeCalculator:
    @pytest.mark.asyncio
    async def test_gas_fee_for_privileged_execute_contract_message(self):
        network = Network.testnet(node="sentry")
        client = AsyncClient(network=network)
        composer = Composer(network=network.string())
        calculator = MessageBasedTransactionFeeCalculator(
            client=client,
            composer=composer,
            gas_price=5_000_000,
        )

        message = tx_pb2.MsgPrivilegedExecuteContract()
        transaction = Transaction()
        transaction.with_messages(message)

        await calculator.configure_gas_fee_for_transaction(transaction=transaction, private_key=None, public_key=None)

        expected_transaction_gas_limit = 60_000
        expected_gas_limit = math.ceil(Decimal(6) * 150_000 + expected_transaction_gas_limit)
        assert expected_gas_limit == transaction.fee.gas_limit
        assert str(expected_gas_limit * 5_000_000) == transaction.fee.amount[0].amount

    @pytest.mark.asyncio
    async def test_gas_fee_for_execute_contract_message(self):
        network = Network.testnet(node="sentry")
        client = AsyncClient(network=network)
        composer = Composer(network=network.string())
        calculator = MessageBasedTransactionFeeCalculator(
            client=client,
            composer=composer,
            gas_price=5_000_000,
        )

        message = composer.MsgExecuteContract(
            sender="",
            contract="",
            msg="",
        )
        transaction = Transaction()
        transaction.with_messages(message)

        await calculator.configure_gas_fee_for_transaction(transaction=transaction, private_key=None, public_key=None)

        expected_transaction_gas_limit = 60_000
        expected_gas_limit = math.ceil(Decimal(2.5) * 150_000 + expected_transaction_gas_limit)
        assert expected_gas_limit == transaction.fee.gas_limit
        assert str(expected_gas_limit * 5_000_000) == transaction.fee.amount[0].amount

    @pytest.mark.asyncio
    async def test_gas_fee_for_wasm_message(self):
        network = Network.testnet(node="sentry")
        client = AsyncClient(network=network)
        composer = Composer(network=network.string())
        calculator = MessageBasedTransactionFeeCalculator(
            client=client,
            composer=composer,
            gas_price=5_000_000,
        )

        message = wasm_tx_pb2.MsgInstantiateContract2()
        transaction = Transaction()
        transaction.with_messages(message)

        await calculator.configure_gas_fee_for_transaction(transaction=transaction, private_key=None, public_key=None)

        expected_transaction_gas_limit = 60_000
        expected_gas_limit = math.ceil(Decimal(1.5) * 150_000 + expected_transaction_gas_limit)
        assert expected_gas_limit == transaction.fee.gas_limit
        assert str(expected_gas_limit * 5_000_000) == transaction.fee.amount[0].amount

    @pytest.mark.asyncio
    async def test_gas_fee_for_governance_message(self):
        network = Network.testnet(node="sentry")
        client = AsyncClient(network=network)
        composer = Composer(network=network.string())
        calculator = MessageBasedTransactionFeeCalculator(
            client=client,
            composer=composer,
            gas_price=5_000_000,
        )

        message = gov_tx_pb2.MsgDeposit()
        transaction = Transaction()
        transaction.with_messages(message)

        await calculator.configure_gas_fee_for_transaction(transaction=transaction, private_key=None, public_key=None)

        expected_transaction_gas_limit = 60_000
        expected_gas_limit = math.ceil(Decimal(15) * 150_000 + expected_transaction_gas_limit)
        assert expected_gas_limit == transaction.fee.gas_limit
        assert str(expected_gas_limit * 5_000_000) == transaction.fee.amount[0].amount

    @pytest.mark.asyncio
    async def test_gas_fee_for_exchange_message(self):
        network = Network.testnet(node="sentry")
        client = AsyncClient(network=network)
        composer = Composer(network=network.string())
        calculator = MessageBasedTransactionFeeCalculator(
            client=client,
            composer=composer,
            gas_price=5_000_000,
        )

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
        transaction = Transaction()
        transaction.with_messages(message)

        await calculator.configure_gas_fee_for_transaction(transaction=transaction, private_key=None, public_key=None)

        expected_transaction_gas_limit = 60_000
        expected_gas_limit = math.ceil(Decimal(1) * 100_000 + expected_transaction_gas_limit)
        assert expected_gas_limit == transaction.fee.gas_limit
        assert str(expected_gas_limit * 5_000_000) == transaction.fee.amount[0].amount

    @pytest.mark.asyncio
    async def test_gas_fee_for_msg_exec_message(self):
        network = Network.testnet(node="sentry")
        client = AsyncClient(network=network)
        composer = Composer(network=network.string())
        calculator = MessageBasedTransactionFeeCalculator(
            client=client,
            composer=composer,
            gas_price=5_000_000,
        )

        inner_message = composer.MsgCreateSpotLimitOrder(
            sender="sender",
            market_id="0x0611780ba69656949525013d947713300f56c37b6175e02f26bffa495c3208fe",
            subaccount_id="subaccount_id",
            fee_recipient="fee_recipient",
            price=7.523,
            quantity=0.01,
            is_buy=True,
            is_po=False,
        )
        message = composer.MsgExec(grantee="grantee", msgs=[inner_message])
        transaction = Transaction()
        transaction.with_messages(message)

        await calculator.configure_gas_fee_for_transaction(transaction=transaction, private_key=None, public_key=None)

        expected_transaction_gas_limit = 60_000
        expected_inner_message_gas_limit = Decimal(1) * 100_000
        expected_exec_message_gas_limit = 5_000
        expected_gas_limit = math.ceil(
            expected_exec_message_gas_limit + expected_inner_message_gas_limit + expected_transaction_gas_limit
        )
        assert expected_gas_limit == transaction.fee.gas_limit
        assert str(expected_gas_limit * 5_000_000) == transaction.fee.amount[0].amount

    @pytest.mark.asyncio
    async def test_gas_fee_for_two_messages_in_one_transaction(self):
        network = Network.testnet(node="sentry")
        client = AsyncClient(network=network)
        composer = Composer(network=network.string())
        calculator = MessageBasedTransactionFeeCalculator(
            client=client,
            composer=composer,
            gas_price=5_000_000,
        )

        inner_message = composer.MsgCreateSpotLimitOrder(
            sender="sender",
            market_id="0x0611780ba69656949525013d947713300f56c37b6175e02f26bffa495c3208fe",
            subaccount_id="subaccount_id",
            fee_recipient="fee_recipient",
            price=7.523,
            quantity=0.01,
            is_buy=True,
            is_po=False,
        )
        message = composer.MsgExec(grantee="grantee", msgs=[inner_message])

        send_message = composer.MsgSend(from_address="address", to_address="to_address", amount=1, denom="INJ")

        transaction = Transaction()
        transaction.with_messages(message, send_message)

        await calculator.configure_gas_fee_for_transaction(transaction=transaction, private_key=None, public_key=None)

        expected_transaction_gas_limit = 60_000
        expected_inner_message_gas_limit = Decimal(1) * 100_000
        expected_exec_message_gas_limit = 5_000
        expected_send_message_gas_limit = 150_000
        expected_gas_limit = math.ceil(
            expected_exec_message_gas_limit
            + expected_inner_message_gas_limit
            + expected_send_message_gas_limit
            + expected_transaction_gas_limit
        )
        assert expected_gas_limit == transaction.fee.gas_limit
        assert str(expected_gas_limit * 5_000_000) == transaction.fee.amount[0].amount
