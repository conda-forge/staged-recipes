from collections import deque

from pyinjective.proto.exchange import injective_derivative_exchange_rpc_pb2, injective_spot_exchange_rpc_pb2
from pyinjective.proto.exchange.injective_derivative_exchange_rpc_pb2_grpc import InjectiveDerivativeExchangeRPCServicer
from pyinjective.proto.exchange.injective_spot_exchange_rpc_pb2_grpc import InjectiveSpotExchangeRPCServicer


class ConfigurableInjectiveSpotExchangeRPCServicer(InjectiveSpotExchangeRPCServicer):
    def __init__(self):
        super().__init__()
        self.markets_queue = deque()

    async def Markets(self, request: injective_spot_exchange_rpc_pb2.MarketsRequest, context=None):
        return self.markets_queue.pop()


class ConfigurableInjectiveDerivativeExchangeRPCServicer(InjectiveDerivativeExchangeRPCServicer):
    def __init__(self):
        super().__init__()
        self.markets_queue = deque()
        self.binary_option_markets_queue = deque()

    async def Markets(self, request: injective_derivative_exchange_rpc_pb2.MarketsRequest, context=None):
        return self.markets_queue.pop()

    async def BinaryOptionsMarkets(
        self, request: injective_derivative_exchange_rpc_pb2.BinaryOptionsMarketsRequest, context=None
    ):
        return self.binary_option_markets_queue.pop()
