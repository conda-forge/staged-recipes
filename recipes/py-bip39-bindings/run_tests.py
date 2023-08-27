# Python BIP39 Bindings
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


class MyTestCase(unittest.TestCase):
    mnemonic = "daughter song common combine misery cotton audit morning stuff weasel flee field"
    mini_secret = [49, 98, 91, 191, 124, 49, 124, 0, 208, 99, 248, 41, 196, 131, 195, 96, 115, 127, 171, 82, 16, 205,
                   187, 45, 20, 195, 40, 22, 91, 21, 209, 128]
    seed = [97, 142, 41, 83, 73, 179, 98, 128, 176, 134, 250, 222, 64, 184, 51, 176, 121, 119, 215, 115, 220, 77, 28,
            15, 253, 64, 10, 1, 213, 54, 239, 124]

    def test_generate_mnemonic(self):
        mnemonic = bip39.bip39_generate(12)
        self.assertTrue(bip39.bip39_validate(mnemonic))

    def test_generate_mnemonic_french(self):
        mnemonic = bip39.bip39_generate(12, 'fr')
        self.assertTrue(bip39.bip39_validate(mnemonic, 'fr'))

    def test_generate_invalid_mnemonic(self):
        self.assertRaises(ValueError, bip39.bip39_generate, 13)

    def test_validate_mnemonic(self):
        self.assertTrue(bip39.bip39_validate(self.mnemonic))

    def test_validate_mnemonic_zh_hans(self):
        self.assertTrue(bip39.bip39_validate('观 敲 荣 硬 责 雪 专 宴 醇 飞 图 菌', 'zh-hans'))

    def test_validate_mnemonic_fr(self):
        self.assertTrue(bip39.bip39_validate(
            'moufle veinard tronc magasin merle amour toboggan admettre biotype décembre régalien billard', 'fr'
        ))

    def test_invalidate_mnemonic(self):
        self.assertFalse(bip39.bip39_validate("invalid mnemonic"))

    def test_mini_seed(self):
        self.assertEqual(self.mini_secret, bip39.bip39_to_mini_secret(self.mnemonic, ''))

    def test_mini_seed_zh_hans(self):

        mini_secret = bip39.bip39_to_mini_secret('观 敲 荣 硬 责 雪 专 宴 醇 飞 图 菌', '', 'zh-hans')
        self.assertEqual(
            [60, 215, 169, 79, 32, 218, 203, 59, 53, 155, 18, 234, 160, 215, 97, 30, 176, 243, 224, 103, 240, 114, 170,
             26, 4, 63, 250, 164, 88, 148, 41, 68], mini_secret)

    def test_invalid_mini_seed(self):
        self.assertRaises(ValueError, bip39.bip39_to_mini_secret, 'invalid mnemonic', '')

    def test_seed(self):
        self.assertEqual(self.seed, bip39.bip39_to_seed(self.mnemonic, ''))

    def test_seed_zh_hans(self):
        mnemonic = '旅 滨 昂 园 扎 点 郎 能 指 死 爬 根'
        seed = bip39.bip39_to_seed(mnemonic, '', 'zh-hans')

        self.assertEqual(
            '3e349679fd7fb457810d578a8b63237c6ba1fd09b39d7f33650c0f879a2cdc46',
            bytes(seed).hex()
        )

    def test_seed_fr(self):
        mnemonic = 'moufle veinard tronc magasin merle amour toboggan admettre biotype décembre régalien billard'
        seed = bip39.bip39_to_seed(mnemonic, '', 'fr')

        self.assertEqual(
            'fe7ca72e2de46c24f121cf649057202ffdd9a51e63fc9fd98f8614fc68c6bbff',
            bytes(seed).hex()
        )

    def test_invalid_seed(self):
        self.assertRaises(ValueError, bip39.bip39_to_seed, 'invalid mnemonic', '')

    def test_invalid_language_code(self):
        with self.assertRaises(ValueError) as e:
            bip39.bip39_generate(12, "unknown")

        self.assertEqual('Invalid language_code', str(e.exception))


if __name__ == '__main__':
    unittest.main()
