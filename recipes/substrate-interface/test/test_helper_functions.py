# Python Substrate Interface Library
#
# Copyright 2018-2020 Stichting Polkascan (Polkascan Foundation).
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

from scalecodec import GenericExtrinsic
from scalecodec.type_registry import load_type_registry_file, load_type_registry_preset
from substrateinterface.exceptions import SubstrateRequestException
from scalecodec.base import ScaleBytes
from substrateinterface import SubstrateInterface, Keypair
from test.settings import POLKADOT_NODE_URL


class TestHelperFunctions(unittest.TestCase):

    test_metadata_version = 'V13'

    @classmethod
    def setUpClass(cls):

        cls.substrate = SubstrateInterface(url='dummy', ss58_format=42, type_registry_preset='kusama')

        cls.metadata_fixture_dict = load_type_registry_file(
            os.path.join(os.path.dirname(__file__), 'fixtures', 'metadata_hex.json')
        )

        metadata_decoder = cls.substrate.runtime_config.create_scale_object('MetadataVersioned')
        metadata_decoder.decode(ScaleBytes(cls.metadata_fixture_dict[cls.test_metadata_version]))

        cls.substrate.get_block_metadata = MagicMock(return_value=metadata_decoder)

        def mocked_request(method, params):
            if method == 'state_getRuntimeVersion':
                return {
                    "jsonrpc": "2.0",
                    "result": {"specVersion": 2023},
                    "id": 1
                }
            elif method == 'chain_getHeader':
                return {
                    "jsonrpc": "2.0",
                    "result": {
                        "digest": {
                            "logs": [
                            ]
                        },
                        "extrinsicsRoot": "0xa94148d938c7b7976abf4272dca95724d7a74da2f3649ec0bd53dc3daaedda44",
                        "number": "0x4abaaa",
                        "parentHash": "0xe1781813275653a970b4260298b3858b36d38e072256dad674f7c786a0cae236",
                        "stateRoot": "0xb6aa468385c82d15b343a676b3488d9f141ac100fc548bb8a546f27a7241c44a"
                    },
                    "id": 1
                }
            elif method == 'chain_getHead':
                return {
                    "jsonrpc": "2.0",
                    "result": "0xe1781813275653a970b4260298b3858b36d38e072256dad674f7c786a0cae236",
                    "id": 1
                }
            elif method == 'rpc_methods':
                return {
                    "jsonrpc": "2.0",
                    "result": {'methods': ['account_nextIndex', 'author_hasKey', 'author_hasSessionKeys', 'author_insertKey', 'author_pendingExtrinsics', 'author_removeExtrinsic', 'author_rotateKeys', 'author_submitAndWatchExtrinsic', 'author_submitExtrinsic', 'author_unwatchExtrinsic', 'babe_epochAuthorship', 'chainHead_unstable_body', 'chainHead_unstable_call', 'chainHead_unstable_follow', 'chainHead_unstable_genesisHash', 'chainHead_unstable_header', 'chainHead_unstable_stopBody', 'chainHead_unstable_stopCall', 'chainHead_unstable_stopStorage', 'chainHead_unstable_storage', 'chainHead_unstable_unfollow', 'chainHead_unstable_unpin', 'chainSpec_unstable_chainName', 'chainSpec_unstable_genesisHash', 'chainSpec_unstable_properties', 'chain_getBlock', 'chain_getBlockHash', 'chain_getFinalisedHead', 'chain_getFinalizedHead', 'chain_getHead', 'chain_getHeader', 'chain_getRuntimeVersion', 'chain_subscribeAllHeads', 'chain_subscribeFinalisedHeads', 'chain_subscribeFinalizedHeads', 'chain_subscribeNewHead', 'chain_subscribeNewHeads', 'chain_subscribeRuntimeVersion', 'chain_unsubscribeAllHeads', 'chain_unsubscribeFinalisedHeads', 'chain_unsubscribeFinalizedHeads', 'chain_unsubscribeNewHead', 'chain_unsubscribeNewHeads', 'chain_unsubscribeRuntimeVersion', 'childstate_getKeys', 'childstate_getKeysPaged', 'childstate_getKeysPagedAt', 'childstate_getStorage', 'childstate_getStorageEntries', 'childstate_getStorageHash', 'childstate_getStorageSize', 'dev_getBlockStats', 'grandpa_proveFinality', 'grandpa_roundState', 'grandpa_subscribeJustifications', 'grandpa_unsubscribeJustifications', 'mmr_generateProof', 'mmr_root', 'mmr_verifyProof', 'mmr_verifyProofStateless', 'offchain_localStorageGet', 'offchain_localStorageSet', 'payment_queryFeeDetails', 'payment_queryInfo', 'state_call', 'state_callAt', 'state_getChildReadProof', 'state_getKeys', 'state_getKeysPaged', 'state_getKeysPagedAt', 'state_getMetadata', 'state_getPairs', 'state_getReadProof', 'state_getRuntimeVersion', 'state_getStorage', 'state_getStorageAt', 'state_getStorageHash', 'state_getStorageHashAt', 'state_getStorageSize', 'state_getStorageSizeAt', 'state_queryStorage', 'state_queryStorageAt', 'state_subscribeRuntimeVersion', 'state_subscribeStorage', 'state_traceBlock', 'state_trieMigrationStatus', 'state_unsubscribeRuntimeVersion', 'state_unsubscribeStorage', 'subscribe_newHead', 'sync_state_genSyncSpec', 'system_accountNextIndex', 'system_addLogFilter', 'system_addReservedPeer', 'system_chain', 'system_chainType', 'system_dryRun', 'system_dryRunAt', 'system_health', 'system_localListenAddresses', 'system_localPeerId', 'system_name', 'system_nodeRoles', 'system_peers', 'system_properties', 'system_removeReservedPeer', 'system_reservedPeers', 'system_resetLogFilter', 'system_syncState', 'system_unstable_networkState', 'system_version', 'transaction_unstable_submitAndWatch', 'transaction_unstable_unwatch', 'unsubscribe_newHead']},
                    "id": 1
                }

            raise NotImplementedError(method)

        cls.substrate.rpc_request = MagicMock(side_effect=mocked_request)

        cls.empty_substrate = SubstrateInterface(url='dummy', ss58_format=42, type_registry_preset='kusama')

        def mocked_request(method, params):

            return {'jsonrpc': '2.0', 'result': None, 'id': 1}

        cls.empty_substrate.rpc_request = MagicMock(side_effect=mocked_request)

        cls.error_substrate = SubstrateInterface(url='wss://kusama-rpc.polkadot.io', ss58_format=2, type_registry_preset='kusama')

        # def mocked_request(method, params):
        #     return {'jsonrpc': '2.0', 'error': {
        #         'code': -32602, 'message': 'Generic error message'
        #     }, 'id': 1}
        #
        # cls.error_substrate.rpc_request = MagicMock(side_effect=mocked_request)

    def test_decode_scale(self):
        self.assertEqual(self.substrate.decode_scale('Compact<u32>', '0x08'), 2)

    def test_encode_scale(self):
        self.assertEqual(self.substrate.encode_scale('Compact<u32>', 3), ScaleBytes('0x0c'))

    def test_create_scale_object(self):
        scale_obj = self.substrate.create_scale_object("Bytes")

        self.assertEqual(scale_obj.encode("Test"), ScaleBytes("0x1054657374"))
        self.assertEqual(scale_obj.decode(ScaleBytes("0x1054657374")), "Test")

    def test_get_type_definition(self):
        info = self.substrate.get_type_definition('MultiSignature')
        self.assertDictEqual({'Ed25519': 'h512', 'Sr25519': 'h512', 'Ecdsa': '[u8; 65]'}, info)

        info = self.substrate.get_type_definition('Balance')
        self.assertEqual('u128', info)

    def test_get_metadata(self):
        metadata = self.substrate.get_metadata()

        self.assertIsNotNone(metadata)
        self.assertEqual(metadata.__class__.__name__, 'MetadataVersioned')

    def test_get_metadata_modules(self):
        for module in self.substrate.get_metadata_modules():
            self.assertIn('module_id', module)
            self.assertIn('name', module)
            self.assertEqual(module['spec_version'], 2023)

    def test_get_metadata_call_function(self):
        call_function = self.substrate.get_metadata_call_function("Balances", "transfer")
        self.assertEqual("transfer", call_function.name)
        self.assertEqual('dest', call_function.args[0].name)
        self.assertEqual('value', call_function.args[1].name)

    def test_get_metadata_call_functions(self):
        call_functions = self.substrate.get_metadata_call_functions()
        self.assertGreater(len(call_functions), 0)

    def test_get_metadata_event(self):
        event = self.substrate.get_metadata_event("Balances", "Transfer")
        self.assertEqual("Transfer", event.name)
        self.assertEqual('AccountId', event.args[0].type)
        self.assertEqual('AccountId', event.args[1].type)
        self.assertEqual('Balance', event.args[2].type)

    def test_get_metadata_constant(self):
        constant = self.substrate.get_metadata_constant("System", "BlockHashCount")
        self.assertEqual("BlockHashCount", constant.name)
        self.assertEqual("BlockNumber", constant.type)
        self.assertEqual("0x60090000", f"0x{constant.constant_value.hex()}")

    def test_get_metadata_constants(self):
        constants = self.substrate.get_metadata_constants()
        self.assertGreater(len(constants), 0)

    def test_get_constant(self):
        constant = self.substrate.get_constant("System", "BlockHashCount")
        self.assertEqual(2400, constant.value)

        constant = self.substrate.get_constant("Balances", "ExistentialDeposit")
        self.assertEqual(100000000000000, constant.value)

        # Also test cache method doesn't mix up results
        constant = self.substrate.get_constant("System", "BlockHashCount")
        self.assertEqual(2400, constant.value)

    def test_get_metadata_storage_function(self):
        storage = self.substrate.get_metadata_storage_function("System", "Account")
        self.assertEqual("Account", storage.name)
        self.assertEqual("AccountId", storage.get_params_type_string()[0])
        self.assertEqual("Blake2_128Concat", storage.type['Map']['hasher'])

    def test_get_metadata_storage_functions(self):
        storages = self.substrate.get_metadata_storage_functions()
        self.assertGreater(len(storages), 0)

    def test_get_metadata_error(self):
        error = self.substrate.get_metadata_error("System", "InvalidSpecName")
        self.assertEqual("InvalidSpecName", error.name)
        self.assertIsNotNone(error.docs)

    def test_get_metadata_errors(self):
        errors = self.substrate.get_metadata_errors()
        self.assertGreater(len(errors), 0)

    def test_helper_functions_should_return_null_not_exists(self):
        self.assertIsNone(self.empty_substrate.get_block_number(
            block_hash="0x6666666666666666666666666666666666666666666666666666666666666666"
        ))

        self.assertIsNone(self.empty_substrate.get_block_hash(block_id=99999999999999999))
        self.assertIsNone(self.empty_substrate.get_block_header(block_hash='0x'))
        self.assertIsNone(self.empty_substrate.get_block_metadata(block_hash='0x')['result'])
        self.assertIsNone(self.empty_substrate.get_block_runtime_version(block_hash='0x'))

    def test_helper_functions_invalid_input(self):
        self.assertRaises(SubstrateRequestException, self.error_substrate.get_block_number, "0x6666666666666666")
        self.assertRaises(SubstrateRequestException, self.error_substrate.get_block_hash, -1)
        self.assertRaises(SubstrateRequestException, self.error_substrate.get_block_header, '0x')
        self.assertRaises(SubstrateRequestException, self.error_substrate.get_block_metadata, '0x')
        self.assertRaises(SubstrateRequestException, self.error_substrate.get_block_runtime_version, '0x')
        self.assertRaises(ValueError, self.error_substrate.query, 'System', 'Account', ['0x'])

    def test_storage_function_param_info(self):
        storage_function = self.substrate.get_metadata_storage_function("System", "Account")
        with self.assertRaises(NotImplementedError):
            storage_function.get_param_info()


class TestHelperFunctionsV14(TestHelperFunctions):
    test_metadata_version = 'V14'

    def test_get_metadata_constant(self):
        constant = self.substrate.get_metadata_constant("System", "BlockHashCount")
        self.assertEqual("BlockHashCount", constant.name)
        self.assertEqual("scale_info::4", constant.type)
        self.assertEqual("0x60090000", f"0x{constant.constant_value.hex()}")

    def test_get_metadata_storage_function(self):
        storage = self.substrate.get_metadata_storage_function("System", "Account")
        self.assertEqual("Account", storage.name)
        self.assertEqual("scale_info::0", storage.get_params_type_string()[0])
        self.assertEqual("Blake2_128Concat", storage.type['Map']['hashers'][0])

    def test_get_metadata_event(self):
        event = self.substrate.get_metadata_event("Balances", "Transfer")
        self.assertEqual("Transfer", event.name)
        self.assertEqual('scale_info::0', event.args[0].type)
        self.assertEqual('scale_info::0', event.args[1].type)
        self.assertEqual('scale_info::6', event.args[2].type)

    def test_storage_function_param_info(self):
        storage_function = self.substrate.get_metadata_storage_function("System", "Account")
        info = storage_function.get_param_info()
        self.assertEqual(1, len(info))
        self.assertEqual('AccountId', info[0])


class TestHelperFunctionsKarura(TestHelperFunctionsV14):
    test_metadata_version = 'karura_test'

    def test_storage_function_param_info(self):
        storage_function = self.substrate.get_metadata_storage_function("Tokens", "TotalIssuance")
        info = storage_function.get_param_info()

        self.assertEqual(1, len(info))
        self.assertEqual('ACA', info[0]['Token'][0])

        storage_function = self.substrate.get_metadata_storage_function("Rewards", "PoolInfos")
        info = storage_function.get_param_info()

        self.assertEqual(1, len(info))
        self.assertEqual('ACA', info[0]['Loans']['Token'][0])

        storage_function = self.substrate.get_metadata_storage_function("Dex", "TradingPairStatuses")
        info = storage_function.get_param_info()

        self.assertEqual(1, len(info))
        self.assertEqual(2, len(info[0]))
        self.assertEqual('ACA', info[0][0]['Token'][0])

    def test_get_metadata_constant(self):
        constant = self.substrate.get_metadata_constant("System", "BlockHashCount")
        self.assertEqual("BlockHashCount", constant.name)
        self.assertEqual("scale_info::4", constant.type)
        self.assertEqual("0xb0040000", f"0x{constant.constant_value.hex()}")

    def test_get_constant(self):
        constant = self.substrate.get_constant("System", "BlockHashCount")
        self.assertEqual(1200, constant.value)

        constant = self.substrate.get_constant("Balances", "ExistentialDeposit")
        self.assertEqual(100000000000, constant.value)

        # Also test cache method doesn't mix up results
        constant = self.substrate.get_constant("System", "BlockHashCount")
        self.assertEqual(1200, constant.value)


class TestRPCHelperFunctions(unittest.TestCase):

    @classmethod
    def setUpClass(cls) -> None:
        cls.substrate = SubstrateInterface(url=POLKADOT_NODE_URL)
        cls.substrate.orig_rpc_request = cls.substrate.rpc_request

        def mocked_request(method, params):
            if method == 'author_pendingExtrinsics':
                return {
                    'jsonrpc': '2.0', 'result': [
                        '0x910584002534454d30f8a028e42654d6b535e0651d1d026ddf115cef59ae1dd71bae074e00245ee2a4e2189bb0d8ab6b2d573fd224d2d902c1e136b3bf1aa4b288ecf59843f3f795ba9b1c072503315866760f5e447ee50cfbc015177ad476f3d5d43aa803c5002e040f00001a021805000019e3a788a770a10d14cbc6b3a0955addef7c48bf2556a656d68df39e97535150070008f6a4e8050000c56832bef06e12549a2ea67ce2cd390b207e0185045f9f2138bced0155e6dfca0b00dfc1961c01050000113bb2aaa8e32ea117dec6f8e30512b4f3fa72259caaad78a2075187c0c2bc7d075c796ec10405000065e6879c5f78d90b9c2e80b5ba5a1ad8eefdb5a592d779317a64748396352c060714fdeca60a050000ba5a44203f0f0aef04913d8cbceca016c27088b3c0cdacced6fa0785ecf6b46e078071e5492a05000009ebb8c62e3fb085a84a912d4b54aa9555ee30084d964172df298200c65ffb080700e0c71817',
                        '0xe9098400c6a7919e4d7051a1285070b6f5a80e882d858942ca21a32e62598ad72b2bee4c01ce0f96a2d4a2f8033038bea0f4b1f9bc1e761662f9ee56f8f5016c804d8f140d95e24ce428ee6a125779b1bfe7cbf562babe87f3b6a7779d78e1b93e3d2dfc884503080007054000b2e07be4d6d82f546ec91d6009ee215bb736be5b4362e66e7b466ec72d47624f0004926296ae6c9155557a6c5aac98d9775664efd8607e894ef210fa2c80b6594100d05490aa747179f2b895c2c5171e9cb10a474fd07d1a8069389678e165369e5600fabfc151a66d7cbd2cfebbdea1954d13fa4721a568a8086386f445c2cefa261c00ca0c59a8141101a8f9c99e3f8a85c77b0ccb57ca6121cf9edc436092e9bbd17c0032aee225f2714c573eec965a9dd1e1ca399636d9158ce068842f0558f360a435008ae437cc2420c617f2cdec05405db6c449bada7d2b2063eadeae636a25c5ca790094211c46d7bb07c67c2bc80e7d5ba4623f8ef0d565d266723ec60497f0375b3b00587b19cc62e01cdc18a1499cda27b0fb33264d0c3817668609bb58f76201269800d6c29a7c39cee45b0e045a94081bc188ef73be2be086d66aefd850fc7eeacc4500f278bbe8c33fe8fe03c6c684b44dfc26dfb5bcefb3ef511f5446530af859c1120066ced89b9a76de4d3dc384b45fdf0bd2f1629f15dd3e44ea14c31ba16181a25500b9f26de7808ffcf087492fc04a2c00178c3bf9ae512d1fc817f8430f6009380100c6477bfd57c12587b1075a80d944c7829784eed61a5c8b8255817e1d62d1070e002c2a55b59ed1954e80bf1349ee5882d429d261cf9962bc5d88a1fc176e60c918008e41df7864847ec31fc0168967dd5b7912c21f4a597438c697f7f4c1a29c4d57'],
                    'id': 17
                }

            return cls.substrate.orig_rpc_request(method, params)

        cls.substrate.rpc_request = MagicMock(side_effect=mocked_request)

    def test_pending_extrinsics(self):
        pending_extrinsics = self.substrate.retrieve_pending_extrinsics()

        self.assertEqual(len(pending_extrinsics), 2)
        self.assertIsInstance(pending_extrinsics[0], GenericExtrinsic)
        self.assertIsInstance(pending_extrinsics[1], GenericExtrinsic)


class SS58HelperTestCase(unittest.TestCase):

    @classmethod
    def setUpClass(cls) -> None:
        cls.keypair = Keypair.create_from_uri('//Alice')

        cls.substrate = SubstrateInterface(url=POLKADOT_NODE_URL)

    def test_ss58_decode(self):

        public_key = self.substrate.ss58_decode("15oF4uVJwmo4TdGW7VfQxNLavjCXviqxT9S1MgbjMNHr6Sp5")

        self.assertEqual("d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d", public_key)

    def test_ss58_encode(self):
        ss58_address = self.substrate.ss58_encode("d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d")
        self.assertEqual("15oF4uVJwmo4TdGW7VfQxNLavjCXviqxT9S1MgbjMNHr6Sp5", ss58_address)

        ss58_address = self.substrate.ss58_encode("0xd43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d")
        self.assertEqual("15oF4uVJwmo4TdGW7VfQxNLavjCXviqxT9S1MgbjMNHr6Sp5", ss58_address)

        ss58_address = self.substrate.ss58_encode(
            bytes.fromhex("d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d")
        )
        self.assertEqual("15oF4uVJwmo4TdGW7VfQxNLavjCXviqxT9S1MgbjMNHr6Sp5", ss58_address)

    def test_ss58_encode_custom_format(self):
        ss58_address = self.substrate.ss58_encode(
            "0xd43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d", ss58_format=2
        )
        self.assertEqual("HNZata7iMYWmk5RvZRTiAsSDhV8366zq2YGb3tLH5Upf74F", ss58_address)


if __name__ == '__main__':
    unittest.main()
