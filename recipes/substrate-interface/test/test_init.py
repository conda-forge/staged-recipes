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

from substrateinterface import SubstrateInterface
from test import settings


class TestInit(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.kusama_substrate = SubstrateInterface(url=settings.KUSAMA_NODE_URL)
        cls.polkadot_substrate = SubstrateInterface(url=settings.POLKADOT_NODE_URL)

    def test_chain(self):
        self.assertEqual('Kusama', self.kusama_substrate.chain)
        self.assertEqual('Polkadot', self.polkadot_substrate.chain)

    def test_properties(self):
        self.assertDictEqual(
            {'ss58Format': 2, 'tokenDecimals': 12, 'tokenSymbol': 'KSM'}, self.kusama_substrate.properties
        )
        self.assertDictEqual(
            {'ss58Format': 0, 'tokenDecimals': 10, 'tokenSymbol': 'DOT'}, self.polkadot_substrate.properties
        )

    def test_ss58_format(self):
        self.assertEqual(2, self.kusama_substrate.ss58_format)
        self.assertEqual(0, self.polkadot_substrate.ss58_format)

    def test_token_symbol(self):
        self.assertEqual('KSM', self.kusama_substrate.token_symbol)
        self.assertEqual('DOT', self.polkadot_substrate.token_symbol)

    def test_token_decimals(self):
        self.assertEqual(12, self.kusama_substrate.token_decimals)
        self.assertEqual(10, self.polkadot_substrate.token_decimals)

    def test_override_ss58_format_init(self):
        substrate = SubstrateInterface(url=settings.KUSAMA_NODE_URL, ss58_format=99)
        self.assertEqual(99, substrate.ss58_format)

    def test_override_incorrect_ss58_format(self):
        substrate = SubstrateInterface(url=settings.KUSAMA_NODE_URL)
        with self.assertRaises(TypeError):
            substrate.ss58_format = 'test'

    def test_override_token_symbol(self):
        substrate = SubstrateInterface(url=settings.KUSAMA_NODE_URL)
        substrate.token_symbol = 'TST'
        self.assertEqual('TST', substrate.token_symbol)

    def test_override_incorrect_token_decimals(self):
        substrate = SubstrateInterface(url=settings.KUSAMA_NODE_URL)
        with self.assertRaises(TypeError):
            substrate.token_decimals = 'test'

    def test_is_valid_ss58_address(self):
        self.assertTrue(self.kusama_substrate.is_valid_ss58_address('GLdQ4D4wkeEJUX8DBT9HkpycFVYQZ3fmJyQ5ZgBRxZ4LD3S'))
        self.assertFalse(
            self.kusama_substrate.is_valid_ss58_address('12gX42C4Fj1wgtfgoP624zeHrcPBqzhb4yAENyvFdGX6EUnN')
        )
        self.assertFalse(
            self.kusama_substrate.is_valid_ss58_address('5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY')
        )

        self.assertFalse(self.polkadot_substrate.is_valid_ss58_address('GLdQ4D4wkeEJUX8DBT9HkpycFVYQZ3fmJyQ5ZgBRxZ4LD3S'))
        self.assertTrue(
            self.polkadot_substrate.is_valid_ss58_address('12gX42C4Fj1wgtfgoP624zeHrcPBqzhb4yAENyvFdGX6EUnN')
        )

    def test_lru_cache_not_shared(self):
        block_number = self.kusama_substrate.get_block_number("0xa4d873095aeae6fc1f3953f0a0085ee216bf8629342aaa92bd53f841e1052e1c")
        block_number2 = self.polkadot_substrate.get_block_number(
            "0xa4d873095aeae6fc1f3953f0a0085ee216bf8629342aaa92bd53f841e1052e1c")

        self.assertIsNotNone(block_number)
        self.assertIsNone(block_number2)

    def test_context_manager(self):
        with SubstrateInterface(url=settings.KUSAMA_NODE_URL) as substrate:
            self.assertTrue(substrate.websocket.connected)
            self.assertEqual(2, substrate.ss58_format)

        self.assertFalse(substrate.websocket.connected)


if __name__ == '__main__':
    unittest.main()
