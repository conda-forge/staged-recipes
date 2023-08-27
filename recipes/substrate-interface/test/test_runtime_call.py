# Python Substrate Interface Library
#
# Copyright 2018-2022 Stichting Polkascan (Polkascan Foundation).
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

from substrateinterface import SubstrateInterface, Keypair
from substrateinterface.exceptions import StorageFunctionNotFound
from test import settings


class RuntimeCallTestCase(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.substrate = SubstrateInterface(
            url=settings.POLKADOT_NODE_URL,
            ss58_format=0,
            type_registry_preset='polkadot'
        )
        # Create new keypair
        mnemonic = Keypair.generate_mnemonic()
        cls.keypair = Keypair.create_from_mnemonic(mnemonic)

    def test_core_version(self):
        result = self.substrate.runtime_call("Core", "version")

        self.assertGreater(result.value['spec_version'], 0)
        self.assertEqual('polkadot', result.value['spec_name'])

    def test_core_version_at_not_best_block(self):
        parent_hash = self.substrate.get_block_header()['header']['parentHash']
        result = self.substrate.runtime_call("Core", "version", block_hash = parent_hash)

        self.assertGreater(result.value['spec_version'], 0)
        self.assertEqual('polkadot', result.value['spec_name'])

    def test_transaction_payment(self):
        call = self.substrate.compose_call(
            call_module='Balances',
            call_function='transfer',
            call_params={
                'dest': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk',
                'value': 3 * 10 ** 3
            }
        )

        extrinsic = self.substrate.create_signed_extrinsic(call=call, keypair=self.keypair, tip=1)
        extrinsic_len = self.substrate.create_scale_object('u32')
        extrinsic_len.encode(len(extrinsic.data))

        result = self.substrate.runtime_call("TransactionPaymentApi", "query_fee_details", [extrinsic, extrinsic_len])

        self.assertGreater(result.value['inclusion_fee']['base_fee'], 0)
        self.assertEqual(0, result.value['tip'])

    def test_metadata_call_info(self):

        runtime_call = self.substrate.get_metadata_runtime_call_function("TransactionPaymentApi", "query_fee_details")
        param_info = runtime_call.get_param_info()
        self.assertEqual('Extrinsic', param_info[0])
        self.assertEqual('u32', param_info[1])

        runtime_call = self.substrate.get_metadata_runtime_call_function("Core", "initialise_block")
        param_info = runtime_call.get_param_info()
        self.assertEqual('u32', param_info[0]['number'])
        self.assertEqual('h256', param_info[0]['parent_hash'])

    def test_check_all_runtime_call_types(self):
        runtime_calls = self.substrate.get_metadata_runtime_call_functions()
        for runtime_call in runtime_calls:
            param_info = runtime_call.get_param_info()
            self.assertEqual(type(param_info), list)
            result_obj = self.substrate.create_scale_object(runtime_call.value['type'])
            info = result_obj.generate_type_decomposition()
            self.assertIsNotNone(info)

    def test_unknown_runtime_call(self):
        with self.assertRaises(ValueError):
            self.substrate.runtime_call("Foo", "bar")


if __name__ == '__main__':
    unittest.main()
