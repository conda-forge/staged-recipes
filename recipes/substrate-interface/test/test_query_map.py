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

import unittest
from unittest.mock import MagicMock

from scalecodec.types import GenericAccountId

from substrateinterface.exceptions import SubstrateRequestException

from substrateinterface import SubstrateInterface
from test import settings


class QueryMapTestCase(unittest.TestCase):

    @classmethod
    def setUpClass(cls):

        cls.kusama_substrate = SubstrateInterface(
            url=settings.KUSAMA_NODE_URL,
            ss58_format=2,
            type_registry_preset='kusama'
        )

        orig_rpc_request = cls.kusama_substrate.rpc_request

        def mocked_request(method, params):
            if method == 'state_getKeysPaged':
                if params[3] == '0x2e8047826d028f5cc092f5e694860efbd4f74ee1535424cdf3626a175867db62':

                    if params[2] == params[0]:
                        return {
                            'jsonrpc': '2.0',
                            'result': [
                                '0x9c5d795d0297be56027a4b2464e333979c5d795d0297be56027a4b2464e3339700000a9c44f24e314127af63ae55b864a28d7aee',
                                '0x9c5d795d0297be56027a4b2464e333979c5d795d0297be56027a4b2464e3339700002f21194993a750972574e2d82ce8c95078a6',
                                '0x9c5d795d0297be56027a4b2464e333979c5d795d0297be56027a4b2464e333970000a940f973ccf435ae9c040c253e1c043c5fb2',
                                '0x9c5d795d0297be56027a4b2464e333979c5d795d0297be56027a4b2464e3339700010b75619f666c3f172f0d1c7fa86d02adcf9c'
                            ],
                            'id': 8
                        }
                    else:
                        return {
                            'jsonrpc': '2.0',
                            'result': [
                            ],
                            'id': 8
                        }
            return orig_rpc_request(method, params)

        cls.kusama_substrate.rpc_request = MagicMock(side_effect=mocked_request)

    def test_claims_claim_map(self):

        result = self.kusama_substrate.query_map('Claims', 'Claims', max_results=3)

        records = [item for item in result]

        self.assertEqual(3, len(records))
        self.assertEqual(45880000000000, records[0][1].value)
        self.assertEqual('0x00000a9c44f24e314127af63ae55b864a28d7aee', records[0][0].value)
        self.assertEqual('0x00002f21194993a750972574e2d82ce8c95078a6', records[1][0].value)
        self.assertEqual('0x0000a940f973ccf435ae9c040c253e1c043c5fb2', records[2][0].value)

    def test_system_account_map_block_hash(self):

        # Retrieve first two records from System.Account query map

        result = self.kusama_substrate.query_map(
            'System', 'Account', page_size=1,
            block_hash="0x587a1e69871c09f2408d724ceebbe16edc4a69139b5df9786e1057c4d041af73"
        )

        record_1_1 = next(result)

        self.assertEqual(type(record_1_1[0]), GenericAccountId)
        self.assertIn('data', record_1_1[1].value)
        self.assertIn('nonce', record_1_1[1].value)

        # Next record set must trigger RPC call

        record_1_2 = next(result)

        self.assertEqual(type(record_1_2[0]), GenericAccountId)
        self.assertIn('data', record_1_2[1].value)
        self.assertIn('nonce', record_1_2[1].value)

        # Same query map with yield of 2 must result in same records

        result = self.kusama_substrate.query_map(
            'System', 'Account', page_size=2,
            block_hash="0x587a1e69871c09f2408d724ceebbe16edc4a69139b5df9786e1057c4d041af73"
        )

        record_2_1 = next(result)
        record_2_2 = next(result)

        self.assertEqual(record_1_1[0].value, record_2_1[0].value)
        self.assertEqual(record_1_1[1].value, record_2_1[1].value)
        self.assertEqual(record_1_2[0].value, record_2_2[0].value)
        self.assertEqual(record_1_2[1].value, record_2_2[1].value)

    def test_max_results(self):
        result = self.kusama_substrate.query_map('Claims', 'Claims', max_results=5, page_size=100)

        # Keep iterating shouldn't trigger retrieve next page
        result_count = 0
        for _ in result:
            result_count += 1

        self.assertEqual(5, result_count)

        result = self.kusama_substrate.query_map('Claims', 'Claims', max_results=5, page_size=2)

        # Keep iterating shouldn't exceed max_results
        result_count = 0
        for record in result:
            result_count += 1
            if result_count == 1:
                self.assertEqual('0x00000a9c44f24e314127af63ae55b864a28d7aee', record[0].value)
            elif result_count == 2:
                self.assertEqual('0x00002f21194993a750972574e2d82ce8c95078a6', record[0].value)
            elif result_count == 3:
                self.assertEqual('0x0000a940f973ccf435ae9c040c253e1c043c5fb2', record[0].value)

        self.assertEqual(5, result_count)

    def test_result_exhausted(self):
        result = self.kusama_substrate.query_map(
            module='Claims', storage_function='Claims',
            block_hash='0x2e8047826d028f5cc092f5e694860efbd4f74ee1535424cdf3626a175867db62'
        )

        result_count = 0
        for _ in result:
            result_count += 1

        self.assertEqual(4, result_count)

    def test_non_existing_query_map(self):
        with self.assertRaises(ValueError) as cm:
            self.kusama_substrate.query_map("Unknown", "StorageFunction")

        self.assertEqual('Pallet "Unknown" not found', str(cm.exception))

    def test_non_map_function_query_map(self):
        with self.assertRaises(ValueError) as cm:
            self.kusama_substrate.query_map("System", "Events")

        self.assertEqual('Given storage function is not a map', str(cm.exception))

    def test_exceed_maximum_page_size(self):
        with self.assertRaises(SubstrateRequestException):
            self.kusama_substrate.query_map(
                'System', 'Account', page_size=9999999
            )

    def test_double_map(self):
        era_stakers = self.kusama_substrate.query_map(
            module='Staking',
            storage_function='ErasStakers',
            params=[2185],
            max_results=4,
            block_hash="0x61dd66907df3187fd1438463f2c87f0d596797936e0a292f6f98d12841da2325"
        )

        records = list(era_stakers)

        self.assertEqual(len(records), 4)
        self.assertEqual(records[0][0].ss58_address, 'JCghFN7mD4ETKzMbvSVmMMPwWutJGk6Bm1yKWk8Z9KhPGeZ')
        self.assertEqual(records[1][0].ss58_address, 'CmNv7yFV13CMM6r9dJYgdi4UTJK7tzFEF17gmK9c3mTc2PG')
        self.assertEqual(records[2][0].ss58_address, 'DfishveZoxSRNRb8FtyS7ignbw6cr32eCY2w6ctLDRM1NQz')
        self.assertEqual(records[3][0].ss58_address, 'HmsTAS1bCtZc9FSq9nqJzZCEkhhSygtXj9TDxNgEWTHnpyQ')

    def test_double_map_page_size(self):
        era_stakers = self.kusama_substrate.query_map(
            module='Staking',
            storage_function='ErasStakers',
            params=[2185],
            max_results=4,
            page_size=1,
            block_hash="0x61dd66907df3187fd1438463f2c87f0d596797936e0a292f6f98d12841da2325"
        )

        records = list(era_stakers)

        self.assertEqual(len(records), 4)
        self.assertEqual(records[0][0].ss58_address, 'JCghFN7mD4ETKzMbvSVmMMPwWutJGk6Bm1yKWk8Z9KhPGeZ')
        self.assertEqual(records[1][0].ss58_address, 'CmNv7yFV13CMM6r9dJYgdi4UTJK7tzFEF17gmK9c3mTc2PG')
        self.assertEqual(records[2][0].ss58_address, 'DfishveZoxSRNRb8FtyS7ignbw6cr32eCY2w6ctLDRM1NQz')
        self.assertEqual(records[3][0].ss58_address, 'HmsTAS1bCtZc9FSq9nqJzZCEkhhSygtXj9TDxNgEWTHnpyQ')

    def test_double_map_no_result(self):
        era_stakers = self.kusama_substrate.query_map(
            module='Staking',
            storage_function='ErasStakers',
            params=[21000000],
            block_hash="0x61dd66907df3187fd1438463f2c87f0d596797936e0a292f6f98d12841da2325"
        )
        self.assertEqual(era_stakers.records, [])

    def test_nested_keys(self):

        result = self.kusama_substrate.query_map(
            module='ConvictionVoting',
            storage_function='VotingFor',
            max_results=10
        )
        self.assertTrue(self.kusama_substrate.is_valid_ss58_address(result[0][0][0].value))
        self.assertGreaterEqual(result[0][0][1], 0)

    def test_double_map_too_many_params(self):
        with self.assertRaises(ValueError) as cm:
            self.kusama_substrate.query_map(
                module='Staking',
                storage_function='ErasStakers',
                params=[21000000, 2]
            )
        self.assertEqual('Storage function map can accept max 1 parameters, 2 given', str(cm.exception))

    def test_map_with_param(self):
        with self.assertRaises(ValueError) as cm:
            self.kusama_substrate.query_map(
                module='System',
                storage_function='Account',
                params=[2]
            )
        self.assertEqual('Storage function map can accept max 0 parameters, 1 given', str(cm.exception))


if __name__ == '__main__':
    unittest.main()
