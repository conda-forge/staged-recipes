# Python Substrate Interface Library
#
# Copyright 2018-2021 Stichting Polkascan (Polkascan Foundation).
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

import unittest
from unittest.mock import MagicMock

from test import settings

from scalecodec.exceptions import RemainingScaleBytesNotEmptyException

from substrateinterface import SubstrateInterface

from test.fixtures import metadata_node_template_hex

from scalecodec.base import ScaleBytes
from scalecodec.types import Vec, GenericAddress


class BlockTestCase(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.substrate = SubstrateInterface(url='dummy', ss58_format=42, type_registry_preset='substrate-node-template')
        metadata_decoder = cls.substrate.runtime_config.create_scale_object(
            'MetadataVersioned', ScaleBytes(metadata_node_template_hex)
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
                        "number": "0x67",
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
                                "extrinsics": [
                                    "0x280402000b940572437701",
                                    "0x45028400be5ddb1579b72e84524fc29e78609e3caf42e85aa118ebfe0b0ad404b5bdd25f011233c8f6642150e92ac029fd4fae2435f524f9ec72794a565e68b9b97c6ce363af37cb1ba27b5b17b23b31ce9573f6be2312d5219d93e50dde0ff6b47c2fca84950100000500008eaf04151687736326c9fea17e25fc5287613693c912909cb226aa4794f26a480b00204aa9d101"
                                ],
                                "header": {
                                    "digest": {
                                        "logs": ['0x06424142453402000000007c4e1f2000000000', '0x054241424501014630c672ca0561bb045d30cba349f9768560bd66cb40ca1c88fcf345f0d8d63b31d179c2cede66d584cf199a457ba436e9f621bfe0b89bf998069b3ed3d2548e']
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
                    "result": {'methods': ['account_nextIndex', 'author_hasKey', 'author_hasSessionKeys', 'author_insertKey', 'author_pendingExtrinsics', 'author_removeExtrinsic', 'author_rotateKeys', 'author_submitAndWatchExtrinsic', 'author_submitExtrinsic', 'author_unwatchExtrinsic', 'babe_epochAuthorship', 'chainHead_unstable_body', 'chainHead_unstable_call', 'chainHead_unstable_follow', 'chainHead_unstable_genesisHash', 'chainHead_unstable_header', 'chainHead_unstable_stopBody', 'chainHead_unstable_stopCall', 'chainHead_unstable_stopStorage', 'chainHead_unstable_storage', 'chainHead_unstable_unfollow', 'chainHead_unstable_unpin', 'chainSpec_unstable_chainName', 'chainSpec_unstable_genesisHash', 'chainSpec_unstable_properties', 'chain_getBlock', 'chain_getBlockHash', 'chain_getFinalisedHead', 'chain_getFinalizedHead', 'chain_getHead', 'chain_getHeader', 'chain_getRuntimeVersion', 'chain_subscribeAllHeads', 'chain_subscribeFinalisedHeads', 'chain_subscribeFinalizedHeads', 'chain_subscribeNewHead', 'chain_subscribeNewHeads', 'chain_subscribeRuntimeVersion', 'chain_unsubscribeAllHeads', 'chain_unsubscribeFinalisedHeads', 'chain_unsubscribeFinalizedHeads', 'chain_unsubscribeNewHead', 'chain_unsubscribeNewHeads', 'chain_unsubscribeRuntimeVersion', 'childstate_getKeys', 'childstate_getKeysPaged', 'childstate_getKeysPagedAt', 'childstate_getStorage', 'childstate_getStorageEntries', 'childstate_getStorageHash', 'childstate_getStorageSize', 'dev_getBlockStats', 'grandpa_proveFinality', 'grandpa_roundState', 'grandpa_subscribeJustifications', 'grandpa_unsubscribeJustifications', 'mmr_generateProof', 'mmr_root', 'mmr_verifyProof', 'mmr_verifyProofStateless', 'offchain_localStorageGet', 'offchain_localStorageSet', 'payment_queryFeeDetails', 'payment_queryInfo', 'state_call', 'state_callAt', 'state_getChildReadProof', 'state_getKeys', 'state_getKeysPaged', 'state_getKeysPagedAt', 'state_getMetadata', 'state_getPairs', 'state_getReadProof', 'state_getRuntimeVersion', 'state_getStorage', 'state_getStorageAt', 'state_getStorageHash', 'state_getStorageHashAt', 'state_getStorageSize', 'state_getStorageSizeAt', 'state_queryStorage', 'state_queryStorageAt', 'state_subscribeRuntimeVersion', 'state_subscribeStorage', 'state_traceBlock', 'state_trieMigrationStatus', 'state_unsubscribeRuntimeVersion', 'state_unsubscribeStorage', 'subscribe_newHead', 'sync_state_genSyncSpec', 'system_accountNextIndex', 'system_addLogFilter', 'system_addReservedPeer', 'system_chain', 'system_chainType', 'system_dryRun', 'system_dryRunAt', 'system_health', 'system_localListenAddresses', 'system_localPeerId', 'system_name', 'system_nodeRoles', 'system_peers', 'system_properties', 'system_removeReservedPeer', 'system_reservedPeers', 'system_resetLogFilter', 'system_syncState', 'system_unstable_networkState', 'system_version', 'transaction_unstable_submitAndWatch', 'transaction_unstable_unwatch', 'unsubscribe_newHead']},
                    "id": 1
                }

            raise ValueError(f"Unsupported mocked method {method}")

        cls.substrate.rpc_request = MagicMock(side_effect=mocked_request)
        cls.substrate.query = MagicMock(side_effect=mocked_query)

        cls.babe_substrate = SubstrateInterface(
            url=settings.BABE_NODE_URL
        )

        cls.aura_substrate = SubstrateInterface(
            url=settings.AURA_NODE_URL
        )

    def test_get_valid_extrinsics(self):

        block = self.substrate.get_block(
            block_hash="0xec828914eca09331dad704404479e2899a971a9b5948345dc40abca4ac818f93"
        )
        extrinsics = block['extrinsics']

        self.assertEqual(extrinsics[0]['call']['call_module'].name, 'Timestamp')
        self.assertEqual(extrinsics[0]['call']['call_function'].name, 'set')
        self.assertEqual(extrinsics[0]['call']['call_args']['now'], 1611744282004)

    def test_get_by_block_number(self):

        block = self.substrate.get_block(
            block_number=100
        )
        extrinsics = block['extrinsics']

        self.assertEqual(extrinsics[0]['call']['call_module'].name, 'Timestamp')
        self.assertEqual(extrinsics[0]['call']['call_function'].name, 'set')
        self.assertEqual(extrinsics[0]['call']['call_args']['now'], 1611744282004)

    def test_get_block_by_head(self):

        block = self.substrate.get_block()
        self.assertEqual('0xec828914eca09331dad704404479e2899a971a9b5948345dc40abca4ac818f93', block['header']['hash'])

    def test_get_block_by_finalized_head(self):

        block = self.substrate.get_block(finalized_only=True)
        self.assertEqual('0xec828914eca09331dad704404479e2899a971a9b5948345dc40abca4ac818f93', block['header']['hash'])

    def test_get_block_header(self):

        block = self.substrate.get_block_header(
            block_number=100
        )
        self.assertNotIn('extrinsics', block)

    def test_get_block_header_by_head(self):

        block = self.substrate.get_block_header()
        self.assertEqual('0xec828914eca09331dad704404479e2899a971a9b5948345dc40abca4ac818f93', block['header']['hash'])

    def test_get_block_header_by_finalized_head(self):

        block = self.substrate.get_block_header(finalized_only=True)
        self.assertEqual('0xec828914eca09331dad704404479e2899a971a9b5948345dc40abca4ac818f93', block['header']['hash'])

    def test_get_extrinsics_decoding_error(self):

        with self.assertRaises(RemainingScaleBytesNotEmptyException):
            self.substrate.get_block(
                block_hash="0x40b98c29466fa76eeee21008b50d5cb5d7220712ead554eb97a5fd6ba4bc31b5"
            )

    def test_get_extrinsics_ignore_decoding_error(self):

        block = self.substrate.get_block(
            block_hash="0x40b98c29466fa76eeee21008b50d5cb5d7220712ead554eb97a5fd6ba4bc31b5",
            ignore_decoding_errors=True
        )

        extrinsics = block['extrinsics']

        self.assertEqual(extrinsics[0], None)
        self.assertEqual(extrinsics[1], None)
        self.assertEqual(extrinsics[2].value['call']['call_args'][0]['value'], 1611744282004)
        self.assertEqual(extrinsics[3], None)

    def test_include_author(self):

        block = self.substrate.get_block(
            block_hash="0xec828914eca09331dad704404479e2899a971a9b5948345dc40abca4ac818f93", include_author=False
        )

        self.assertNotIn('author', block)

        block = self.substrate.get_block(
            block_hash="0xec828914eca09331dad704404479e2899a971a9b5948345dc40abca4ac818f93", include_author=True
        )

        self.assertIn('author', block)
        self.assertEqual('5GNJqTPyNqANBkUVMN1LPPrxXnFouWXoe2wNSmmEoLctxiZY', block['author'])

    def test_subscribe_block_headers(self):

        def subscription_handler(obj, update_nr, subscription_id):
            return f"callback: {obj['header']['number']}"

        result = self.substrate.subscribe_block_headers(subscription_handler)

        self.assertEqual(f"callback: 103", result)

    def test_check_requirements(self):
        self.assertRaises(ValueError, self.substrate.get_block,
                          block_hash='0xec828914eca09331dad704404479e2899a971a9b5948345dc40abca4ac818f93',
                          block_number=223
                          )
        self.assertRaises(ValueError, self.substrate.get_block,
                          block_hash='0xec828914eca09331dad704404479e2899a971a9b5948345dc40abca4ac818f93',
                          finalized_only=True
                          )
        self.assertRaises(ValueError, self.substrate.get_block_header,
                          block_hash='0xec828914eca09331dad704404479e2899a971a9b5948345dc40abca4ac818f93',
                          block_number=223
                          )
        self.assertRaises(ValueError, self.substrate.get_block_header,
                          block_hash='0xec828914eca09331dad704404479e2899a971a9b5948345dc40abca4ac818f93',
                          finalized_only=True
                          )

    def test_block_author_babe(self):
        block = self.babe_substrate.get_block(include_author=True)

        self.assertIn('author', block)
        self.assertIsNotNone(block['author'])

    def test_block_author_aura(self):
        block = self.aura_substrate.get_block(include_author=True)

        self.assertIn('author', block)
        self.assertIsNotNone(block['author'])


if __name__ == '__main__':
    unittest.main()
