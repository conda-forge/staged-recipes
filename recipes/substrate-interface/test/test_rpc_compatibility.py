# Python Substrate Interface Library
#
# Copyright 2018-2023 Stichting Polkascan (Polkascan Foundation).
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
import os
import unittest
from unittest.mock import MagicMock

from scalecodec.type_registry import load_type_registry_file
from test import settings

from scalecodec.exceptions import RemainingScaleBytesNotEmptyException

from substrateinterface import SubstrateInterface

from scalecodec.base import ScaleBytes
from scalecodec.types import Vec, GenericAddress


class RPCCompatilibityTestCase(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.metadata_fixture_dict = load_type_registry_file(
            os.path.join(os.path.dirname(__file__), 'fixtures', 'metadata_hex.json')
        )

        cls.substrate = SubstrateInterface(url='dummy', ss58_format=42, type_registry_preset='substrate-node-template')
        metadata_decoder = cls.substrate.runtime_config.create_scale_object(
            'MetadataVersioned', ScaleBytes(cls.metadata_fixture_dict['V14'])
        )
        metadata_decoder.decode()
        cls.substrate.get_block_metadata = MagicMock(return_value=metadata_decoder)

        def mocked_query(module, storage_function, block_hash):
            if module == 'Session' and storage_function == 'Validators':
                if block_hash == '0xec828914eca09331dad704404479e2899a971a9b5948345dc40abca4ac818f93':
                    vec = Vec()
                    author = GenericAddress()
                    author.value = '5GNJqTPyNqANBkUVMN1LPPrxXnFouWXoe2wNSmmEoLctxiZY'
                    vec.elements = [author]
                    return vec

            raise ValueError(f"Unsupported mocked query {module}.{storage_function} @ {block_hash}")

        def mocked_request(method, params, result_handler=None):

            if method in ['chain_getBlockHash', 'chain_getHead', 'chain_getFinalisedHead', 'chain_getFinalizedHead']:
                return {
                    "jsonrpc": "2.0",
                    "result": "0xec828914eca09331dad704404479e2899a971a9b5948345dc40abca4ac818f93",
                    "id": 1
                }
            elif method in ['chain_getRuntimeVersion', 'state_getRuntimeVersion']:
                return {
                    "jsonrpc": "2.0",
                    "result": {"specVersion": 100, "transactionVersion": 1},
                    "id": 1
                }
            elif method == 'chain_getHeader':
                return {
                    "jsonrpc": "2.0",
                    "result": {
                        "digest": {
                            "logs": ['0x066175726120afe0021000000000', '0x05617572610101567be3d55b4885ce3ac6a7b46b28adf138299acc3eb5f11ffa15c3ed0551f22b7220ec676ea947cd6c8daa6fcfa351b11e62651e6e06f5dde59bb566d36e6989']
                        },
                        "extrinsicsRoot": "0xeaa9cd48b36a88ba7cf934cdbcd8f2afc0843978912452529ace7ef2da09691d",
                        "number": 3158840,
                        "parentHash": "0xf33015565b9978d146cdf648c498649b04c323cd35d9f55fad7d8586d4b42ea2",
                        "stateRoot": "0xa8b0c74dbf09ee9ff5443076f8298027e3a6505ab6e3f6a683a7d4d137130683"
                    },
                    "id": 1
                }
            elif method == 'chain_getBlock':
                # Correct
                if params[0] == '0xec828914eca09331dad704404479e2899a971a9b5948345dc40abca4ac818f93':
                    return {
                        "jsonrpc": "2.0",
                        "result": {
                            "block": {
                                "extrinsics": ['0x280403000b695f47ff8601'],
                                "header": {
                                    "digest": {'logs': [{'preRuntime': ['0x6e6d6273', '0x6a3f02ac48ee3080aa304fe6c336d6c75b302e08041a5c1d6a9a30541f51b618']}, {'preRuntime': ['0x72616e64', '0xe468581da52a51330797c9f5762d98a241f28b3bde9017307e15cfc9a6ebb6741e7da1282681401b26752a04073ea98335005699817e546db343b457fcc7150cdf9edabb3a7b8e35acd6e763235c9ce415bdb0a22d98024cb6410beeb74d3903']}, {'consensus': ['0x66726f6e', '0x019ad160fc5080a49795f34607dadc267a0a0485dc0e6fa46c0ded42ac102a92813090c50b4ff02aed1ca173df1f8915d9872e47a6c3c71a0a32d36d342d6c00ab9f50a496f171bad265ab5a3512568e1234cdab03f7ee1a98ce6e489d5726deed3c125f5c342d0662ccfcea93d2c34c35f328b183af68502ea9e2a72e83522dd7f884ac7a067b4e5cfae4766fd0b2159809cbe3d1af7eb1747c1a3e675982bd9312b90c5020048fef1349759f22b20a919af96ae7270dd40614eb7345ce35beff07980cb675de6be9bafd8fd2e2322cd2fce6f24d0a23c8a68adcced46da0be3b280ead3a25348bb9e6f7a90aac0a2d8a3d8badcb94c3929a5fd898146ecfd361b39de60b7a194a6e4751aa8b54c435a7a9a6af274700b870528ff0780f6ca63ba7449d5534fb786e33900b30966970f29db6310244860409dd6af96a09f9b82946d3f47a61c3bfb21a43e257b3ddf56d07ce8bfdbcb2c277eca96ebe95a8042ec0faf5d65a20505c1562aba4bde857552766320c61fd748c260a0c334a4bfec1ffedbb288cc8bd3348e4c48bd67118ce3936e3fc67b90aeebab97dbda0f6cfeb7e']}, {'seal': ['0x6e6d6273', '0x561e0be2c6f495f326fbc1bf67943f5ff087133d42860fb1dbe8f260deb4570110e1aab58f6f4064ec1839b351987489bf027e274ae593b52c88d99ae6b92f8e']}]},
                                    "extrinsicsRoot": "0xeaa9cd48b36a88ba7cf934cdbcd8f2afc0843978912452529ace7ef2da09691d",
                                    "number": "0x67",
                                    "parentHash": "0xf33015565b9978d146cdf648c498649b04c323cd35d9f55fad7d8586d4b42ea2",
                                    "stateRoot": "0xa8b0c74dbf09ee9ff5443076f8298027e3a6505ab6e3f6a683a7d4d137130683"
                                }
                            },
                            "justification": None
                        },
                        "id": 1
                    }
                # Raises decoding errors
                elif params[0] == '0x40b98c29466fa76eeee21008b50d5cb5d7220712ead554eb97a5fd6ba4bc31b5':
                    return {
                        "jsonrpc": "2.0",
                        "result": {
                            "block": {
                                "extrinsics": [
                                    "0x240402000b9405724377",
                                    "0x280402100b940572437701",
                                    "0x280402000b940572437701",
                                    "0x280402000c940572437701",
                                ],
                                "header": {
                                    "digest": {
                                        "logs": [
                                            "0x066175726120afe0021000000000",
                                            "0x05617572610101567be3d55b4885ce3ac6a7b46b28adf138299acc3eb5f11ffa15c3ed0551f22b7220ec676ea947cd6c8daa6fcfa351b11e62651e6e06f5dde59bb566d36e6989"
                                        ]
                                    },
                                    "extrinsicsRoot": "0xeaa9cd48b36a88ba7cf934cdbcd8f2afc0843978912452529ace7ef2da09691d",
                                    "number": "0x67",
                                    "parentHash": "0xf33015565b9978d146cdf648c498649b04c323cd35d9f55fad7d8586d4b42ea2",
                                    "stateRoot": "0xa8b0c74dbf09ee9ff5443076f8298027e3a6505ab6e3f6a683a7d4d137130683"
                                }
                            },
                            "justification": None
                        },
                        "id": 1
                    }
            elif method == 'state_getStorageAt':
                return {'jsonrpc': '2.0', 'result': '0x04be5ddb1579b72e84524fc29e78609e3caf42e85aa118ebfe0b0ad404b5bdd25f', 'id': 11}
            elif method == 'chain_subscribeNewHeads':
                return result_handler({
                    "jsonrpc": "2.0",
                    "params": {
                        "result": {
                            "digest": {
                                "logs": ['0x066175726120afe0021000000000', '0x05617572610101567be3d55b4885ce3ac6a7b46b28adf138299acc3eb5f11ffa15c3ed0551f22b7220ec676ea947cd6c8daa6fcfa351b11e62651e6e06f5dde59bb566d36e6989']
                            },
                            "extrinsicsRoot": "0xeaa9cd48b36a88ba7cf934cdbcd8f2afc0843978912452529ace7ef2da09691d",
                            "number": "0x67",
                            "parentHash": "0xf33015565b9978d146cdf648c498649b04c323cd35d9f55fad7d8586d4b42ea2",
                            "stateRoot": "0xa8b0c74dbf09ee9ff5443076f8298027e3a6505ab6e3f6a683a7d4d137130683"
                        },
                        "subscription": 'test1'
                    }
                }, 0, 'test1')
            elif method == 'chain_unsubscribeNewHeads':
                return {
                    "jsonrpc": "2.0",
                    "result": True
                }
            elif method == 'rpc_methods':
                return {
                    "jsonrpc": "2.0",
                    "result": {"methods": ['author_submitExtrinsic', 'author_submitAndWatchExtrinsic', 'author_unwatchExtrinsic', 'author_pendingExtrinsics', 'chain_getBlockHash', 'chain_getHeader', 'chain_getBlock', 'chain_getFinalizedHead', 'chain_subscribeNewHead', 'chain_subscribeFinalizedHeads', 'chain_unsubscribeNewHead', 'chain_subscribeNewHeads', 'chain_unsubscribeNewHeads', 'chain_unsubscribeFinalizedHeads', 'state_getRuntimeVersion', 'state_getMetadata', 'state_getStorage', 'state_getKeysPaged', 'state_queryStorageAt', 'state_call', 'state_subscribeRuntimeVersion', 'state_unsubscribeRuntimeVersion', 'state_subscribeStorage', 'state_unsubscribeStorage', 'system_localPeerId', 'system_nodeRoles', 'system_localListenAddresses', 'system_chain', 'system_properties', 'system_name', 'system_version', 'system_chainType', 'system_health', 'system_dryRun', 'system_accountNextIndex', 'payment_queryFeeDetails', 'payment_queryInfo', 'dev_newBlock', 'dev_setStorage', 'dev_timeTravel', 'dev_setHead', 'dev_dryRun', 'rpc_methods']},
                    "id": 1
                }

            raise ValueError(f"Unsupported mocked method {method}")

        cls.substrate.rpc_request = MagicMock(side_effect=mocked_request)
        cls.substrate.query = MagicMock(side_effect=mocked_query)

    def test_get_block_by_head(self):

        block = self.substrate.get_block()
        self.assertEqual('0xec828914eca09331dad704404479e2899a971a9b5948345dc40abca4ac818f93', block['header']['hash'])

    def test_get_chain_head(self):
        block_hash = self.substrate.get_chain_head()
        self.assertEqual('0xec828914eca09331dad704404479e2899a971a9b5948345dc40abca4ac818f93', block_hash)


if __name__ == '__main__':
    unittest.main()
