# Python ED25519 Bindings
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

import bip39
import ed25519_zebra


class MyTestCase(unittest.TestCase):
    def test_sign_and_verify_message(self):

        message = b"test"

        # Get private and public key from seed
        seed = bip39.bip39_to_mini_secret('daughter song common combine misery cotton audit morning stuff weasel flee field','')
        private_key, public_key = ed25519_zebra.ed_from_seed(bytes(seed))

        # Generate signature
        signature = ed25519_zebra.ed_sign(private_key, message)

        # Verify message with signature
        self.assertTrue(ed25519_zebra.ed_verify(signature, message, public_key))

    def test_verify_signature(self):
        public_key = bytes.fromhex('fd8c9f401e9b5db50685be590b4f8e5a10d4abfef9a532ee903f125fd11f129c')

        signature = bytes.fromhex('33185bf9e8f6b354751ef7c7a7c692b3d51d5096e52c4c08e8b307f804d025f3'
                                  'f14a060b8c1ad11f92fe0be4cae2c620d86d6012f90d071fb8dbadac2774df02')

        # Verify message with signature
        self.assertTrue(ed25519_zebra.ed_verify(signature, b"test", public_key))

    def test_verify_invalid_public_key(self):
        public_key = bytes(1)

        signature = bytes.fromhex('33185bf9e8f6b354751ef7c7a7c692b3d51d5096e52c4c08e8b307f804d025f3'
                                  'f14a060b8c1ad11f92fe0be4cae2c620d86d6012f90d071fb8dbadac2774df02')

        # Verify message with signature
        self.assertFalse(ed25519_zebra.ed_verify(signature, b"test", public_key))

    def test_verify_invalid_signature(self):
        # Get private and public key from seed
        seed = bip39.bip39_to_mini_secret(
            'daughter song common combine misery cotton audit morning stuff weasel flee field', '')
        private_key, public_key = ed25519_zebra.ed_from_seed(bytes(seed))

        # Verify message with signature
        self.assertFalse(ed25519_zebra.ed_verify(bytes(32), b"test", public_key))

    def test_invalid_seed_length(self):
        self.assertRaises(ValueError, ed25519_zebra.ed_from_seed, bytes(1))

    def test_sign_invalid_private_key_length(self):
        with self.assertRaises(ValueError):
            ed25519_zebra.ed_sign(bytes(1), b"test")


if __name__ == '__main__':
    unittest.main()
