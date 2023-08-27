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

from scalecodec.base import ScaleBytes, RuntimeConfigurationObject
from scalecodec.type_registry import load_type_registry_file, load_type_registry_preset

from substrateinterface import SubstrateInterface, Keypair, KeypairType
from test import settings


class KusamaTypeRegistryTestCase(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.substrate = SubstrateInterface(
            url=settings.KUSAMA_NODE_URL,
            ss58_format=2,
            type_registry_preset='kusama'
        )

    def test_type_registry_compatibility(self):

        for scale_type in self.substrate.get_type_registry():
            obj = self.substrate.runtime_config.get_decoder_class(scale_type)

            self.assertIsNotNone(obj, '{} not supported'.format(scale_type))


class PolkadotTypeRegistryTestCase(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.substrate = SubstrateInterface(
            url=settings.POLKADOT_NODE_URL,
            ss58_format=0,
            type_registry_preset='polkadot'
        )

    def test_type_registry_compatibility(self):

        for scale_type in self.substrate.get_type_registry():

            obj = self.substrate.runtime_config.get_decoder_class(scale_type)

            self.assertIsNotNone(obj, '{} not supported'.format(scale_type))


class RococoTypeRegistryTestCase(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.substrate = SubstrateInterface(
            url=settings.ROCOCO_NODE_URL,
            ss58_format=42,
            type_registry_preset='rococo'
        )

    def test_type_registry_compatibility(self):

        for scale_type in self.substrate.get_type_registry():

            obj = self.substrate.runtime_config.get_decoder_class(scale_type)

            self.assertIsNotNone(obj, '{} not supported'.format(scale_type))

#
# class DevelopmentTypeRegistryTestCase(unittest.TestCase):
#
#     @classmethod
#     def setUpClass(cls):
#         cls.substrate = SubstrateInterface(
#             url="ws://127.0.0.1:9944",
#             ss58_format=42,
#             type_registry_preset='development'
#         )
#
#     def test_type_registry_compatibility(self):
#
#         for scale_type in self.substrate.get_type_registry():
#
#             obj = self.substrate.runtime_config.get_decoder_class(scale_type)
#
#             self.assertIsNotNone(obj, '{} not supported'.format(scale_type))


class ReloadTypeRegistryTestCase(unittest.TestCase):

    def setUp(self) -> None:
        self.substrate = SubstrateInterface(
            url='dummy',
            ss58_format=42,
            type_registry_preset='test'
        )

    def test_initial_correct_type_local(self):
        decoding_class = self.substrate.runtime_config.type_registry['types']['index']
        self.assertEqual(self.substrate.runtime_config.get_decoder_class('u32'), decoding_class)

    def test_reloading_use_remote_preset(self):

        # Intentionally overwrite type in local preset
        u32_cls = self.substrate.runtime_config.get_decoder_class('u32')
        u64_cls = self.substrate.runtime_config.get_decoder_class('u64')

        self.substrate.runtime_config.type_registry['types']['index'] = u64_cls

        self.assertEqual(u64_cls, self.substrate.runtime_config.get_decoder_class('Index'))

        # Reload type registry
        self.substrate.reload_type_registry()

        self.assertEqual(u32_cls, self.substrate.runtime_config.get_decoder_class('Index'))

    def test_reloading_use_local_preset(self):

        # Intentionally overwrite type in local preset
        u32_cls = self.substrate.runtime_config.get_decoder_class('u32')
        u64_cls = self.substrate.runtime_config.get_decoder_class('u64')

        self.substrate.runtime_config.type_registry['types']['index'] = u64_cls

        self.assertEqual(u64_cls, self.substrate.runtime_config.get_decoder_class('Index'))

        # Reload type registry
        self.substrate.reload_type_registry(use_remote_preset=False)

        self.assertEqual(u32_cls, self.substrate.runtime_config.get_decoder_class('Index'))


class AutodiscoverV14RuntimeTestCase(unittest.TestCase):
    runtime_config = None
    metadata_obj = None
    metadata_fixture_dict = None

    @classmethod
    def setUpClass(cls):
        module_path = os.path.dirname(__file__)
        cls.metadata_fixture_dict = load_type_registry_file(
            os.path.join(module_path, 'fixtures', 'metadata_hex.json')
        )
        cls.runtime_config = RuntimeConfigurationObject(implements_scale_info=True)
        cls.runtime_config.update_type_registry(load_type_registry_preset("core"))

        cls.metadata_obj = cls.runtime_config.create_scale_object(
            'MetadataVersioned', data=ScaleBytes(cls.metadata_fixture_dict['V14'])
        )
        cls.metadata_obj.decode()

    def setUp(self) -> None:

        class MockedSubstrateInterface(SubstrateInterface):

            def rpc_request(self, method, params, result_handler=None):

                if method == 'system_chain':
                    return {
                        'jsonrpc': '2.0',
                        'result': 'test',
                        'id': self.request_id
                    }

                return super().rpc_request(method, params, result_handler)

        self.substrate = MockedSubstrateInterface(
            url=settings.KUSAMA_NODE_URL
        )

    def test_type_reg_preset_applied(self):
        self.substrate.init_runtime()
        self.assertIsNotNone(self.substrate.runtime_config.get_decoder_class('SpecificTestType'))


class AutodetectAddressTypeTestCase(unittest.TestCase):

    def test_default_substrate_address(self):
        substrate = SubstrateInterface(
            url=settings.POLKADOT_NODE_URL, auto_discover=False
        )

        keypair_alice = Keypair.create_from_uri('//Alice', ss58_format=substrate.ss58_format)

        call = substrate.compose_call(
            call_module='Balances',
            call_function='transfer',
            call_params={
                'dest': keypair_alice.ss58_address,
                'value': 2000
            }
        )

        extrinsic = substrate.create_signed_extrinsic(call, keypair_alice)

        self.assertEqual(extrinsic.value['address'], f'0x{keypair_alice.public_key.hex()}')

    def test_eth_address(self):
        substrate = SubstrateInterface(
            url=settings.MOONBEAM_NODE_URL, auto_discover=False
        )

        keypair_alice = Keypair.create_from_mnemonic(Keypair.generate_mnemonic(), crypto_type=KeypairType.ECDSA)

        call = substrate.compose_call(
            call_module='Balances',
            call_function='transfer',
            call_params={
                'dest': keypair_alice.ss58_address,
                'value': 2000
            }
        )

        extrinsic = substrate.create_signed_extrinsic(call, keypair_alice)

        self.assertEqual(extrinsic.value['address'], f'0x{keypair_alice.public_key.hex()}')


if __name__ == '__main__':
    unittest.main()
