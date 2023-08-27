# Python SR25519 Bindings
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
import sr25519


class MyTestCase(unittest.TestCase):
    message = b"test"
    seed = bip39.bip39_to_mini_secret('daughter song common combine misery cotton audit morning stuff weasel flee field','')
    chain_code = bytes.fromhex('7eadeb0f985ffcab9e50f25a19c1e4c8c2f4cd742049fc35e07c684040057e9a')
    child_index = b"\x01\x02\x03\x04"

    def test_sign_and_verify_message(self):
        # Get private and public key from seed
        public_key, private_key = sr25519.pair_from_seed(bytes(self.seed))

        # Generate signature
        signature = sr25519.sign(
            (public_key, private_key),
            self.message
        )

        # Verify message with signature
        self.assertTrue(sr25519.verify(signature, self.message, public_key))

    def test_sign_ed25519_private_key(self):
        private_key = bytes.fromhex(
            '98319d4ff8a9508c4bb0cf0b5a78d760a0b2082c02775e6e82370816fedfff48925a225d97aa00682d6a59b95b18780c10d7032336e88f3442b42361f4a66011')

        public_key, private_key = sr25519.pair_from_ed25519_secret_key(private_key)

        signature = sr25519.sign(
            (public_key, private_key),
            self.message
        )

        # Verify message with signature
        self.assertTrue(sr25519.verify(signature, self.message, public_key))

    def test_convert_private_key_to_ed25519_expanded(self):

        private_key = bytes.fromhex("33a6f3093f158a7109f679410bef1a0c54168145e0cecb4df006c1c2fffb1f09925a225d97aa00682d6a59b95b18780c10d7032336e88f3442b42361f4a66011")

        priv_key_ed25519 = sr25519.convert_secret_key_to_ed25519(private_key)

        self.assertEqual(bytes.fromhex("98319d4ff8a9508c4bb0cf0b5a78d760a0b2082c02775e6e82370816fedfff48925a225d97aa00682d6a59b95b18780c10d7032336e88f3442b42361f4a66011"), priv_key_ed25519)

    def test_derive_soft(self):
        # Get private and public key from seed
        public_key, private_key = sr25519.pair_from_seed(bytes(self.seed))

        # Private derivation
        child_chain_priv, child_pubkey_priv, child_privkey = sr25519.derive_keypair(
            (self.chain_code, public_key, private_key),
            self.child_index
        )

        # Public derivation
        child_chain_pub, child_pubkey_pub = sr25519.derive_pubkey(
            (self.chain_code, public_key),
            self.child_index
        )

        # Assert that the chain code and public key are the same regardless of
        # derivation method
        self.assertEqual(child_chain_priv, child_chain_pub)
        self.assertEqual(child_pubkey_priv, child_pubkey_pub)

        # Test that signatures with the derived private key are valid
        signature = sr25519.sign(
            (child_pubkey_priv, child_privkey),
            self.message
        )

        self.assertTrue(sr25519.verify(signature, self.message, child_pubkey_pub))

    def test_derive_hard(self):
        # Get private and public key from seed
        public_key, private_key = sr25519.pair_from_seed(bytes(self.seed))

        # Private derivation
        _, child_pubkey, child_privkey = sr25519.hard_derive_keypair(
            (self.chain_code, public_key, private_key),
            self.child_index
        )

        # Test that signatures with the derived private key are valid
        signature = sr25519.sign(
            (child_pubkey, child_privkey),
            self.message
        )

        self.assertTrue(sr25519.verify(signature, self.message, child_pubkey))


if __name__ == '__main__':
    unittest.main()
