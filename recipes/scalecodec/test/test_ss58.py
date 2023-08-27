# Python SCALE Codec Library
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

from scalecodec.utils.ss58 import ss58_decode, ss58_encode, ss58_encode_account_index, ss58_decode_account_index, \
    is_valid_ss58_address


class SS58TestCase(unittest.TestCase):

    @classmethod
    def setUpClass(cls) -> None:

        cls.alice_keypair = {
            'address': '5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY',
            'public_key': '0xd43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d',
            'ss58_format': 42
        }

        cls.subkey_pairs = [
            {
                'address': '5EU9mjvZdLRGyDFiBHjxrxvQuaaBpeTZCguhxM3yMX8cpZ2u',
                'public_key': '0x6a5a5957ce778c174c02c151e7c4917ac127b33ad8485f579f830fc15d31bc5a',
                'ss58_format': 42
            },
            {
                # ecdsa
                'address': '4pbsSkWcBaYoFHrKJZp5fDVUKbqSYD9dhZZGvpp3vQ5ysVs5ybV',
                'public_key': '0x035676109c54b9a16d271abeb4954316a40a32bcce023ac14c8e26e958aa68fba9',
                'ss58_format': 200
            },
            {
                'address': 'yGF4JP7q5AK46d1FPCEm9sYQ4KooSjHMpyVAjLnsCSWVafPnf',
                'public_key': '0x66cd6cf085627d6c85af1aaf2bd10cf843033e929b4e3b1c2ba8e4aa46fe111b',
                'ss58_format': 255
            },
            {
                'address': 'yGDYxQatQwuxqT39Zs4LtcTnpzE12vXb7ZJ6xpdiHv6gTu1hF',
                'public_key': '0x242fd5a078ac6b7c3c2531e9bcf1314343782aeb58e7bc6880794589e701db55',
                'ss58_format': 255
            },
            {
                'address': 'mHm8k9Emsvyfp3piCauSH684iA6NakctF8dySQcX94GDdrJrE',
                'public_key': '0x44d5a3ac156335ea99d33a83c57c7146c40c8e2260a8a4adf4e7a86256454651',
                'ss58_format': 4242
            },
            {
                'address': 'r6Gr4gaMP8TsjhFbqvZhv3YvnasugLiRJpzpRHifsqqG18UXa',
                'public_key': '0x88f01441682a17b52d6ae12d1a5670cf675fd254897efabaa5069eb3a701ab73',
                'ss58_format': 14269
            }
        ]

    def test_encode_key_pair_alice_address(self):
        self.assertEqual(self.alice_keypair['address'], "5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY")

    def test_encode_1_byte_account_index(self):
        self.assertEqual('F7NZ', ss58_encode_account_index(1))

    def test_encode_1_byte_account_index_with_format(self):
        self.assertEqual('g4b', ss58_encode_account_index(1, ss58_format=2))
        self.assertEqual('g4b', ss58_encode('0x01', ss58_format=2))

    def test_encode_2_bytes_account_index(self):
        self.assertEqual('3xygo', ss58_encode_account_index(256, ss58_format=2))
        self.assertEqual('3xygo', ss58_encode('0x0001', ss58_format=2))

    def test_encode_4_bytes_account_index(self):
        self.assertEqual('zswfoZa', ss58_encode_account_index(67305985, ss58_format=2))
        self.assertEqual('zswfoZa', ss58_encode('0x01020304', ss58_format=2))

    def test_encode_8_bytes_account_index(self):
        self.assertEqual('848Gh2GcGaZia', ss58_encode('0x2a2c0a0000000000', ss58_format=2))

    def test_decode_1_byte_account_index(self):
        self.assertEqual(1, ss58_decode_account_index('F7NZ'))

    def test_decode_2_bytes_account_index(self):
        self.assertEqual(256, ss58_decode_account_index('3xygo'))

    def test_decode_4_bytes_account_index(self):
        self.assertEqual(67305985, ss58_decode_account_index('zswfoZa'))

    def test_decode_8_bytes_account_index(self):
        self.assertEqual(666666, ss58_decode_account_index('848Gh2GcGaZia'))

    def test_encode_33_byte_address(self):
        self.assertEqual(
            'KWCv1L3QX9LDPwY4VzvLmarEmXjVJidUzZcinvVnmxAJJCBou',
            ss58_encode('0x03b9dc646dd71118e5f7fda681ad9eca36eb3ee96f344f582fbe7b5bcdebb13077')
        )

    def test_encode_with_2_byte_prefix(self):
        public_key = ss58_decode('5GoKvZWG5ZPYL1WUovuHW3zJBWBP5eT8CbqjdRY4Q6iMaQua')

        self.assertEqual(
            'yGHU8YKprxHbHdEv7oUK4rzMZXtsdhcXVG2CAMyC9WhzhjH2k',
            ss58_encode(public_key, ss58_format=255)
        )

    def test_encode_subkey_generated_pairs(self):
        for subkey_pair in self.subkey_pairs:
            self.assertEqual(
                subkey_pair['address'],
                ss58_encode(address=subkey_pair['public_key'], ss58_format=subkey_pair['ss58_format'])
            )

    def test_decode_subkey_generated_pairs(self):
        for subkey_pair in self.subkey_pairs:
            self.assertEqual(
                subkey_pair['public_key'],
                '0x' + ss58_decode(address=subkey_pair['address'], valid_ss58_format=subkey_pair['ss58_format'])
            )

    def test_invalid_ss58_format_range_exceptions(self):
        with self.assertRaises(ValueError) as cm:
            ss58_encode(self.alice_keypair['public_key'], ss58_format=-1)
        self.assertEqual('Invalid value for ss58_format', str(cm.exception))

        with self.assertRaises(ValueError) as cm:
            ss58_encode(self.alice_keypair['public_key'], ss58_format=16384)

        self.assertEqual('Invalid value for ss58_format', str(cm.exception))

    def test_invalid_reserved_ss58_format(self):
        with self.assertRaises(ValueError) as cm:
            ss58_encode(self.alice_keypair['public_key'], ss58_format=46)

        self.assertEqual('Invalid value for ss58_format', str(cm.exception))

        with self.assertRaises(ValueError) as cm:
            ss58_encode(self.alice_keypair['public_key'], ss58_format=47)

        self.assertEqual('Invalid value for ss58_format', str(cm.exception))

    def test_invalid_public_key(self):
        with self.assertRaises(ValueError) as cm:
            ss58_encode(self.alice_keypair['public_key'][:30])

        self.assertEqual('Invalid length for address', str(cm.exception))

    def test_decode_public_key(self):
        self.assertEqual(
            '0x03b9dc646dd71118e5f7fda681ad9eca36eb3ee96f344f582fbe7b5bcdebb13077',
            ss58_decode('0x03b9dc646dd71118e5f7fda681ad9eca36eb3ee96f344f582fbe7b5bcdebb13077')
        )

    def test_decode_reserved_ss58_formats(self):

        with self.assertRaises(ValueError) as cm:
            ss58_decode('MGP3U1wqNhFofseKXU7B6FcZuLbvQvJFyin1EvQM65mBcNsY8')

        self.assertEqual('46 is a reserved SS58 format', str(cm.exception))

        with self.assertRaises(ValueError) as cm:
            ss58_decode('MhvaLBvSb5jhjrftHLQPAvJegnpXgyDTE1ZprRNzAcfQSRdbL')

        self.assertEqual('47 is a reserved SS58 format', str(cm.exception))

    def test_invalid_ss58_format_check(self):
        with self.assertRaises(ValueError) as cm:
            ss58_decode('5GoKvZWG5ZPYL1WUovuHW3zJBWBP5eT8CbqjdRY4Q6iMaQua', valid_ss58_format=2)

        self.assertEqual('Invalid SS58 format', str(cm.exception))

    def test_decode_invalid_checksum(self):
        with self.assertRaises(ValueError) as cm:
            ss58_decode('5GoKvZWG5ZPYL1WUovuHW3zJBWBP5eT8CbqjdRY4Q6iMaQub')

        self.assertEqual('Invalid checksum', str(cm.exception))

    def test_decode_invalid_length(self):
        with self.assertRaises(ValueError) as cm:
            ss58_decode('5GoKvZWG5ZPYL1WUovuHW3zJBWBP5eT8CbqjdRY4Q6iMaQubsdhfjksdhfkj')

        self.assertEqual('Invalid address length', str(cm.exception))

    def test_decode_empty_string(self):
        with self.assertRaises(ValueError) as cm:
            ss58_decode('')

        self.assertEqual('Empty address provided', str(cm.exception))

    def test_is_valid_ss58_address(self):
        self.assertTrue(is_valid_ss58_address('5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY'))
        self.assertTrue(is_valid_ss58_address('5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY', valid_ss58_format=42))
        self.assertFalse(is_valid_ss58_address('5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY', valid_ss58_format=2))

        self.assertTrue(is_valid_ss58_address('GLdQ4D4wkeEJUX8DBT9HkpycFVYQZ3fmJyQ5ZgBRxZ4LD3S', valid_ss58_format=2))
        self.assertFalse(is_valid_ss58_address('GLdQ4D4wkeEJUX8DBT9HkpycFVYQZ3fmJyQ5ZgBRxZ4LD3S', valid_ss58_format=42))
        self.assertFalse(is_valid_ss58_address('GLdQ4D4wkeEJUX8DBT9HkpycFVYQZ3fmJyQ5ZgBRxZ4LD3S', valid_ss58_format=0))
        self.assertTrue(is_valid_ss58_address('12gX42C4Fj1wgtfgoP624zeHrcPBqzhb4yAENyvFdGX6EUnN', valid_ss58_format=0))

        self.assertFalse(is_valid_ss58_address('5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQ'))
        self.assertFalse(is_valid_ss58_address('6GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY'))
        self.assertFalse(is_valid_ss58_address('0xd43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d'))
        self.assertFalse(is_valid_ss58_address('d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d'))
        self.assertFalse(is_valid_ss58_address('incorrect_string'))


if __name__ == '__main__':
    unittest.main()
