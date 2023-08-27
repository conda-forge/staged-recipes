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

from substrateinterface.constants import DEV_PHRASE
from substrateinterface.key import extract_derive_path
from substrateinterface.exceptions import ConfigurationError
from scalecodec.base import ScaleBytes
from substrateinterface import Keypair, KeypairType, MnemonicLanguageCode


class KeyPairTestCase(unittest.TestCase):

    def test_generate_mnemonic(self):
        mnemonic = Keypair.generate_mnemonic()
        self.assertTrue(Keypair.validate_mnemonic(mnemonic))

    def test_valid_mnemonic(self):
        mnemonic = "old leopard transfer rib spatial phone calm indicate online fire caution review"
        self.assertTrue(Keypair.validate_mnemonic(mnemonic))

    def test_valid_mnemonic_multi_lang(self):
        mnemonic = "秘 心 姜 封 迈 走 描 朗 出 莫 人 口"
        self.assertTrue(Keypair.validate_mnemonic(mnemonic, MnemonicLanguageCode.CHINESE_SIMPLIFIED))

        mnemonic = "nation armure tympan devancer temporel capsule ogive médecin acheter narquois abrasif brasier"
        self.assertTrue(Keypair.validate_mnemonic(mnemonic, MnemonicLanguageCode.FRENCH))

        keypair = Keypair.create_from_mnemonic(mnemonic, language_code=MnemonicLanguageCode.FRENCH)
        self.assertEqual("5FUQmUcb3KAR9rBJekCVcNX1DyPV3n7ZyLfkxohjpbL3xkxR", keypair.ss58_address)

    def test_create_mnemonic_multi_lang(self):
        mnemonic_path = "秘 心 姜 封 迈 走 描 朗 出 莫 人 口//0"
        keypair = Keypair.create_from_uri(mnemonic_path, language_code=MnemonicLanguageCode.CHINESE_SIMPLIFIED)
        self.assertNotEqual(keypair, None)
        self.assertEqual("5CnobodXqobQhfeH6gJj7m8b7yKfSyYpVLneLUSDEbvAKTg3", keypair.ss58_address)

        mnemonic_path = "nation armure tympan devancer temporel capsule ogive médecin acheter narquois abrasif brasier"
        keypair = Keypair.create_from_uri(mnemonic_path, language_code=MnemonicLanguageCode.FRENCH)
        self.assertNotEqual(keypair, None)
        self.assertEqual("5FUQmUcb3KAR9rBJekCVcNX1DyPV3n7ZyLfkxohjpbL3xkxR", keypair.ss58_address)

    def test_invalid_mnemonic(self):
        mnemonic = "This is an invalid mnemonic"
        self.assertFalse(Keypair.validate_mnemonic(mnemonic))

    def test_create_sr25519_keypair(self):
        mnemonic = "old leopard transfer rib spatial phone calm indicate online fire caution review"
        keypair = Keypair.create_from_mnemonic(mnemonic, ss58_format=0)

        self.assertEqual(keypair.ss58_address, "16ADqpMa4yzfmWs3nuTSMhfZ2ckeGtvqhPWCNqECEGDcGgU2")

    def test_only_provide_ss58_address(self):

        keypair = Keypair(ss58_address='16ADqpMa4yzfmWs3nuTSMhfZ2ckeGtvqhPWCNqECEGDcGgU2')
        self.assertEqual(keypair.public_key, bytes.fromhex('e4359ad3e2716c539a1d663ebd0a51bdc5c98a12e663bb4c4402db47828c9446'))

    def test_only_provide_public_key(self):

        keypair = Keypair(
            public_key=bytes.fromhex('e4359ad3e2716c539a1d663ebd0a51bdc5c98a12e663bb4c4402db47828c9446'),
            ss58_format=0
        )
        self.assertEqual(keypair.ss58_address, '16ADqpMa4yzfmWs3nuTSMhfZ2ckeGtvqhPWCNqECEGDcGgU2')

    def test_provide_no_ss58_address_and_public_key(self):
        self.assertRaises(ValueError, Keypair)

    def test_incorrect_private_key_length_sr25519(self):
        self.assertRaises(
            ValueError, Keypair, private_key='0x23', ss58_address='16ADqpMa4yzfmWs3nuTSMhfZ2ckeGtvqhPWCNqECEGDcGgU2'
        )

    def test_incorrect_public_key(self):
        self.assertRaises(ValueError, Keypair, public_key='0x23')

    def test_sign_and_verify(self):
        mnemonic = Keypair.generate_mnemonic()
        keypair = Keypair.create_from_mnemonic(mnemonic)
        signature = keypair.sign("Test123")
        self.assertTrue(keypair.verify("Test123", signature))

    def test_sign_and_verify_multi_lang(self):
        mnemonic = Keypair.generate_mnemonic(language_code=MnemonicLanguageCode.FRENCH)
        keypair = Keypair.create_from_mnemonic(mnemonic, language_code=MnemonicLanguageCode.FRENCH)
        signature = keypair.sign("Test123")
        self.assertTrue(keypair.verify("Test123", signature))

    def test_sign_and_verify_hex_data(self):
        mnemonic = Keypair.generate_mnemonic()
        keypair = Keypair.create_from_mnemonic(mnemonic)
        signature = keypair.sign("0x1234")
        self.assertTrue(keypair.verify("0x1234", signature))

    def test_sign_and_verify_scale_bytes(self):
        mnemonic = Keypair.generate_mnemonic()
        keypair = Keypair.create_from_mnemonic(mnemonic)

        data = ScaleBytes('0x1234')

        signature = keypair.sign(data)
        self.assertTrue(keypair.verify(data, signature))

    def test_sign_and_verify_wrapping(self):
        mnemonic = Keypair.generate_mnemonic()
        keypair = Keypair.create_from_mnemonic(mnemonic)

        signature = keypair.sign('<Bytes>test</Bytes>')
        self.assertTrue(keypair.verify('test', signature))

    def test_sign_missing_private_key(self):
        keypair = Keypair(ss58_address="5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY")
        self.assertRaises(ConfigurationError, keypair.sign, "0x1234")

    def test_sign_unsupported_crypto_type(self):
        keypair = Keypair.create_from_private_key(
            ss58_address='16ADqpMa4yzfmWs3nuTSMhfZ2ckeGtvqhPWCNqECEGDcGgU2',
            private_key='0x1f1995bdf3a17b60626a26cfe6f564b337d46056b7a1281b64c649d592ccda0a9cffd34d9fb01cae1fba61aeed184c817442a2186d5172416729a4b54dd4b84e',
            crypto_type=3
        )
        self.assertRaises(ConfigurationError, keypair.sign, "0x1234")

    def test_verify_unsupported_crypto_type(self):
        keypair = Keypair.create_from_private_key(
            ss58_address='16ADqpMa4yzfmWs3nuTSMhfZ2ckeGtvqhPWCNqECEGDcGgU2',
            private_key='0x1f1995bdf3a17b60626a26cfe6f564b337d46056b7a1281b64c649d592ccda0a9cffd34d9fb01cae1fba61aeed184c817442a2186d5172416729a4b54dd4b84e',
            crypto_type=3
        )
        self.assertRaises(ConfigurationError, keypair.verify, "0x1234", '0x1234')

    def test_sign_and_verify_incorrect_signature(self):
        mnemonic = Keypair.generate_mnemonic()
        keypair = Keypair.create_from_mnemonic(mnemonic)
        signature = "0x4c291bfb0bb9c1274e86d4b666d13b2ac99a0bacc04a4846fb8ea50bda114677f83c1f164af58fc184451e5140cc8160c4de626163b11451d3bbb208a1889f8a"
        self.assertFalse(keypair.verify("Test123", signature))

    def test_sign_and_verify_invalid_signature(self):
        mnemonic = Keypair.generate_mnemonic()
        keypair = Keypair.create_from_mnemonic(mnemonic)
        signature = "Test"
        self.assertRaises(TypeError, keypair.verify, "Test123", signature)

    def test_sign_and_verify_invalid_message(self):
        mnemonic = Keypair.generate_mnemonic()
        keypair = Keypair.create_from_mnemonic(mnemonic)
        signature = keypair.sign("Test123")
        self.assertFalse(keypair.verify("OtherMessage", signature))

    def test_create_ed25519_keypair(self):
        mnemonic = "old leopard transfer rib spatial phone calm indicate online fire caution review"
        keypair = Keypair.create_from_mnemonic(mnemonic, ss58_format=0, crypto_type=KeypairType.ED25519)

        self.assertEqual("16dYRUXznyhvWHS1ktUENGfNAEjCawyDzHRtN9AdFnJRc38h", keypair.ss58_address)

    def test_sign_and_verify_ed25519(self):
        mnemonic = Keypair.generate_mnemonic()
        keypair = Keypair.create_from_mnemonic(mnemonic, crypto_type=KeypairType.ED25519)
        signature = keypair.sign("Test123")

        self.assertTrue(keypair.verify("Test123", signature))

    def test_sign_and_verify_invalid_signature_ed25519(self):
        mnemonic = Keypair.generate_mnemonic()
        keypair = Keypair.create_from_mnemonic(mnemonic, crypto_type=KeypairType.ED25519)
        signature = "0x4c291bfb0bb9c1274e86d4b666d13b2ac99a0bacc04a4846fb8ea50bda114677f83c1f164af58fc184451e5140cc8160c4de626163b11451d3bbb208a1889f8a"
        self.assertFalse(keypair.verify("Test123", signature))

    def test_create_ecdsa_keypair_private_key(self):
        private_key = bytes.fromhex("b516d07cbf975a08adf9465c4864b6d7e348b04c241db5eb8f24d89de629d387")

        keypair = Keypair.create_from_private_key(private_key=private_key, crypto_type=KeypairType.ECDSA)

        self.assertEqual("0xc6A0d8799D596BDd5C30E9ACbe2c63F37c142e35", keypair.ss58_address)
        self.assertEqual(bytes.fromhex("c6A0d8799D596BDd5C30E9ACbe2c63F37c142e35"), keypair.public_key)

    def test_create_ecdsa_keypair_mnemonic(self):

        mnemonic = "old leopard transfer rib spatial phone calm indicate online fire caution review"
        # m/44'/60'/0'/0/0
        keypair = Keypair.create_from_mnemonic(mnemonic, crypto_type=KeypairType.ECDSA)

        self.assertEqual("0xc6A0d8799D596BDd5C30E9ACbe2c63F37c142e35", keypair.ss58_address)

    def test_create_ecdsa_keypair_uri(self):
        mnemonic = "old leopard transfer rib spatial phone calm indicate online fire caution review"

        suri_0 = f"{mnemonic}/m/44'/60'/0'/0/0"

        keypair = Keypair.create_from_uri(suri_0, crypto_type=KeypairType.ECDSA)

        self.assertEqual("0xc6A0d8799D596BDd5C30E9ACbe2c63F37c142e35", keypair.ss58_address)

        suri_1 = f"{mnemonic}/m/44'/60'/0'/0/1"

        keypair = Keypair.create_from_uri(suri_1, crypto_type=KeypairType.ECDSA)

        self.assertEqual("0x571DCd75Cd50852db08951e3A173aC23e44F05c9", keypair.ss58_address)

    def test_sign_and_verify_ecdsa(self):
        mnemonic = Keypair.generate_mnemonic()
        keypair = Keypair.create_from_mnemonic(mnemonic, crypto_type=KeypairType.ECDSA)
        signature = keypair.sign("Test123")

        self.assertTrue(keypair.verify("Test123", signature))

    def test_sign_and_verify_invalid_signature_ecdsa(self):
        mnemonic = Keypair.generate_mnemonic()
        keypair = Keypair.create_from_mnemonic(mnemonic, crypto_type=KeypairType.ECDSA)
        signature = "0x24ff874fddab207ac6cae6a5bfe6e3542bb561abc98a22d1cfd7f8396927cf6d4962e198b5d599cf598b3c14cca98ab16d12569b666e8d33899c46d0d814a58200"
        self.assertFalse(keypair.verify("Test123", signature))

    def test_unsupport_crypto_type(self):
        self.assertRaises(
            ValueError, Keypair.create_from_seed,
            seed_hex='0xda3cf5b1e9144931?a0f0db65664aab662673b099415a7f8121b7245fb0be4143',
            crypto_type=2
        )

    def test_sign_and_verify_bytes(self):
        mnemonic = Keypair.generate_mnemonic()
        keypair = Keypair.create_from_mnemonic(mnemonic)
        signature = keypair.sign(b"Test123")

        self.assertTrue(keypair.verify(b"Test123", signature))

    def test_sign_and_verify_public_ss58_address(self):
        keypair = Keypair.create_from_uri("//Alice", crypto_type=KeypairType.SR25519)
        signature = keypair.sign('test')

        keypair_public = Keypair(ss58_address='5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY',
                                 crypto_type=KeypairType.SR25519)
        self.assertTrue(keypair_public.verify('test', signature))

    def test_sign_and_verify_public_ethereum_address(self):
        keypair = Keypair.create_from_uri("/m/44'/60/0'/0", crypto_type=KeypairType.ECDSA)
        signature = keypair.sign('test')

        keypair_public = Keypair(public_key='0x5e20a619338338772e97aa444e001043da96a43b', crypto_type=KeypairType.ECDSA)
        self.assertTrue(keypair_public.verify('test', signature))

    def test_create_keypair_from_private_key(self):
        keypair = Keypair.create_from_private_key(
            ss58_address='16ADqpMa4yzfmWs3nuTSMhfZ2ckeGtvqhPWCNqECEGDcGgU2',
            private_key='0x1f1995bdf3a17b60626a26cfe6f564b337d46056b7a1281b64c649d592ccda0a9cffd34d9fb01cae1fba61aeed184c817442a2186d5172416729a4b54dd4b84e'
        )
        self.assertEqual(keypair.public_key, bytes.fromhex('e4359ad3e2716c539a1d663ebd0a51bdc5c98a12e663bb4c4402db47828c9446'))

    def test_hdkd_hard_path(self):
        mnemonic = 'old leopard transfer rib spatial phone calm indicate online fire caution review'
        derivation_address = '5FEiH8iuDUw271xbqWTWuB6WrDjv5dnCeDX1CyHubAniXDNN'
        derivation_path = '//Alice'

        derived_keypair = Keypair.create_from_uri(mnemonic + derivation_path)

        self.assertEqual(derivation_address, derived_keypair.ss58_address)

    def test_hdkd_soft_path(self):
        mnemonic = 'old leopard transfer rib spatial phone calm indicate online fire caution review'
        derivation_address = '5GNXbA46ma5dg19GXdiKi5JH3mnkZ8Yea3bBtZAvj7t99P9i'
        derivation_path = '/Alice'

        derived_keypair = Keypair.create_from_uri(mnemonic + derivation_path)

        self.assertEqual(derivation_address, derived_keypair.ss58_address)

    def test_hdkd_default_to_dev_mnemonic(self):
        derivation_address = '5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY'
        derivation_path = '//Alice'

        derived_keypair = Keypair.create_from_uri(derivation_path)

        self.assertEqual(derivation_address, derived_keypair.ss58_address)

    def test_hdkd_create_uri_correct_ss58format(self):
        derivation_address = 'HNZata7iMYWmk5RvZRTiAsSDhV8366zq2YGb3tLH5Upf74F'
        derivation_path = '//Alice'

        derived_keypair = Keypair.create_from_uri(derivation_path, ss58_format=2)

        self.assertEqual(derived_keypair.ss58_format, 2)
        self.assertEqual(derived_keypair.ss58_address, derivation_address)

    def test_hdkd_nested_hard_soft_path(self):
        derivation_address = '5CJGwWiKXSE16WJaxBdPZhWqUYkotgenLUALv7ZvqQ4TXeqf'
        derivation_path = '//Bob/test'

        derived_keypair = Keypair.create_from_uri(derivation_path)

        self.assertEqual(derivation_address, derived_keypair.ss58_address)

    def test_hdkd_nested_soft_hard_path(self):
        derivation_address = '5Cwc8tShrshDJUp1P1M21dKUTcYQpV9GcfSa4hUBNmMdV3Cx'
        derivation_path = '/Bob//test'

        derived_keypair = Keypair.create_from_uri(derivation_path)

        self.assertEqual(derivation_address, derived_keypair.ss58_address)

    def test_hdkd_nested_numeric_hard_path(self):
        derivation_address = '5Fc3qszVcAXHAmjjm61KcxqvV1kh91jpydE476NjjnJneNdP'
        derivation_path = '//polkadot//0'

        derived_keypair = Keypair.create_from_uri(derivation_path)

        self.assertEqual(derivation_address, derived_keypair.ss58_address)

    def test_hdkd_nested_numeric2_hard_path(self):
        derivation_address = '5Dr9GrefZzxfeHovyiKUXKYGKRRiTbPhfLo14iYcHKNccN9q'
        derivation_path = '//1//5000'

        derived_keypair = Keypair.create_from_uri(derivation_path)

        self.assertEqual(derivation_address, derived_keypair.ss58_address)

    def test_hdkd_path_gt_32_bytes(self):
        derivation_address = '5GR5pfZeNs1uQiSWVxZaQiZou3wdZiX894eqgvfNfHbEh7W2'
        derivation_path = '//PathNameLongerThan32BytesWhichShouldBeHashed'

        derived_keypair = Keypair.create_from_uri(derivation_path)

        self.assertEqual(derivation_address, derived_keypair.ss58_address)

    def test_hdkd_path_eq_32_bytes(self):
        derivation_address = '5Ea3JZpvsBN34jiQwVrLiMh5ypaHtPSyM2DWQvLmSRioEmyk'
        derivation_path = '//rococo-validator-profiled-node-0'

        derived_keypair = Keypair.create_from_uri(derivation_path)

        self.assertEqual(derivation_address, derived_keypair.ss58_address)

    def test_hdkd_unsupported_password(self):
        self.assertRaises(NotImplementedError, Keypair.create_from_uri, DEV_PHRASE + '///test')

    def test_reconstruct_path_fail(self):
        self.assertRaises(ValueError, extract_derive_path, 'no_slashes')
        self.assertRaises(ValueError, extract_derive_path, '//')

    def test_encrypt_decrypt_message(self):
        sender = Keypair.create_from_mnemonic("nominee lift horse divert crop quantum proud between pink goose attack market", crypto_type=KeypairType.ED25519)
        recipient = Keypair(ss58_address="5DFZ8UzF5zeCLVPVRMkopNjVyxJNb1dHgGJYFDaVbm4CqNku", crypto_type=KeypairType.ED25519)
        message = "Violence is the last refuge of the incompetent - Isaac Asimov, Foundation"
        message_encrypted = sender.encrypt_message(message, recipient.public_key)
        recipient = Keypair.create_from_mnemonic("almost desk skull craft chuckle bubble hollow innocent require physical purchase rabbit", crypto_type=KeypairType.ED25519)
        sender = Keypair(ss58_address="5DYUhnXkHux1rGTDaS9ACPQekbpSR2J5SyedDQNJVrk4Tn5t", crypto_type=KeypairType.ED25519)
        message_decrypted = recipient.decrypt_message(message_encrypted, sender.public_key).decode("utf-8")
        self.assertEqual(message_decrypted, message)

    def test_hdkd_multi_lang(self):
        mnemonic_path = "秘 心 姜 封 迈 走 描 朗 出 莫 人 口//0"
        keypair = Keypair.create_from_uri(mnemonic_path, language_code=MnemonicLanguageCode.CHINESE_SIMPLIFIED)
        self.assertNotEqual(keypair, None)

        # "é" as multibyte unicode character
        mnemonic_path = "nation armure tympan devancer temporel capsule ogive médecin acheter narquois abrasif brasier//0"
        keypair = Keypair.create_from_uri(mnemonic_path, language_code=MnemonicLanguageCode.FRENCH)
        self.assertNotEqual(keypair, None)

        # "é" as one byte unicode character:
        mnemonic_path = "nation armure tympan devancer temporel capsule ogive médecin acheter narquois abrasif brasier//0"
        keypair = Keypair.create_from_uri(mnemonic_path, language_code=MnemonicLanguageCode.FRENCH)
        self.assertNotEqual(keypair, None)

    def test_create_from_encrypted_json(self):

        keypair_alice = Keypair.create_from_uri('//Alice')

        json_file = os.path.join(os.path.dirname(__file__), 'fixtures', 'polkadotjs_encrypted.json')
        with open(json_file, 'r') as fp:
            json_data = fp.read()
            keypair = Keypair.create_from_encrypted_json(json_data, "test", ss58_format=42)

            self.assertEqual(keypair_alice.ss58_address, keypair.ss58_address)
            self.assertEqual(keypair_alice.public_key, keypair.public_key)
            self.assertEqual(keypair_alice.private_key, keypair.private_key)

            signature = keypair.sign("Test123")
            self.assertTrue(keypair.verify("Test123", signature))

    def test_create_from_encrypted_json_ed25519(self):
        json_file = os.path.join(os.path.dirname(__file__), 'fixtures', 'polkadotjs_encrypted_ed25519.json')
        with open(json_file, 'r') as fp:
            json_data = fp.read()
            keypair = Keypair.create_from_encrypted_json(json_data, "test", ss58_format=42)
            self.assertEqual('5FxjTxVWebYJeoPZ9H6XHkYVxvS5j7MN5jpJwWq7F9Pidz3K', keypair.ss58_address)

            signature = keypair.sign("Test123")
            self.assertTrue(keypair.verify("Test123", signature))

    def test_export_keypair_to_json(self):
        keypair = Keypair.create_from_uri('//Alice')
        json_data = keypair.export_to_encrypted_json(passphrase="test", name="Alice")

        self.assertEqual(json_data['address'], keypair.ss58_address)
        self.assertEqual(json_data['meta']['name'], "Alice")

        keypair_json = Keypair.create_from_encrypted_json(json_data, "test", ss58_format=42)

        self.assertEqual(keypair_json.public_key, keypair.public_key)
        self.assertEqual(keypair_json.private_key, keypair.private_key)


if __name__ == '__main__':
    unittest.main()
