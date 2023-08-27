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

from datetime import datetime, timezone

import unittest

from substrateinterface import SubstrateInterface
from substrateinterface.exceptions import ExtensionCallNotFound
from substrateinterface.extensions import SubstrateNodeExtension
from test import settings


class ExtensionsTestCase(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.substrate = SubstrateInterface(
            url=settings.POLKADOT_NODE_URL
        )
        cls.substrate.register_extension(SubstrateNodeExtension(max_block_range=100))

    def test_search_block_number(self):
        block_datetime = datetime(2020, 7, 12, 0, 0, 0, tzinfo=timezone.utc)

        block_number = self.substrate.extensions.search_block_number(block_datetime=block_datetime)

        self.assertGreaterEqual(block_number, 665270)
        self.assertLessEqual(block_number, 665280)

    def test_search_block_timestamp(self):
        block_timestamp = self.substrate.extensions.get_block_timestamp(1000)
        self.assertEqual(1590513426, block_timestamp)

    def test_unsupported_extension_call(self):
        with self.assertRaises(ExtensionCallNotFound):
            self.substrate.extensions.unknown()


if __name__ == '__main__':
    unittest.main()
