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

from scalecodec import ScaleBytes
from scalecodec.type_registry import load_type_registry_file
from substrateinterface import SubstrateInterface, Keypair, ExtrinsicReceipt
from substrateinterface.exceptions import SubstrateRequestException
from test import settings


class CreateExtrinsicsTestCase(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.kusama_substrate = SubstrateInterface(
            url=settings.KUSAMA_NODE_URL,
            ss58_format=2,
            type_registry_preset='kusama'
        )

        cls.polkadot_substrate = SubstrateInterface(
            url=settings.POLKADOT_NODE_URL,
            ss58_format=0,
            type_registry_preset='polkadot'
        )

        module_path = os.path.dirname(__file__)
        cls.metadata_fixture_dict = load_type_registry_file(
            os.path.join(module_path, 'fixtures', 'metadata_hex.json')
        )

        # Create new keypair
        mnemonic = Keypair.generate_mnemonic()
        cls.keypair = Keypair.create_from_mnemonic(mnemonic)

    def test_create_extrinsic_metadata_v14(self):

        # Create balance transfer call
        call = self.kusama_substrate.compose_call(
            call_module='Balances',
            call_function='transfer',
            call_params={
                'dest': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk',
                'value': 3 * 10 ** 3
            }
        )

        extrinsic = self.kusama_substrate.create_signed_extrinsic(call=call, keypair=self.keypair, tip=1)

        decoded_extrinsic = self.kusama_substrate.create_scale_object("Extrinsic")
        decoded_extrinsic.decode(extrinsic.data)

        self.assertEqual(decoded_extrinsic['call']['call_module'].name, 'Balances')
        self.assertEqual(decoded_extrinsic['call']['call_function'].name, 'transfer')
        self.assertEqual(extrinsic['nonce'], 0)
        self.assertEqual(extrinsic['tip'], 1)

    def test_create_mortal_extrinsic(self):

        for substrate in [self.kusama_substrate, self.polkadot_substrate]:

            # Create balance transfer call
            call = substrate.compose_call(
                call_module='Balances',
                call_function='transfer',
                call_params={
                    'dest': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk',
                    'value': 3 * 10 ** 3
                }
            )

            extrinsic = substrate.create_signed_extrinsic(call=call, keypair=self.keypair, era={'period': 64})

            try:
                substrate.submit_extrinsic(extrinsic)

                self.fail('Should raise no funds to pay fees exception')

            except SubstrateRequestException as e:
                # Extrinsic should be successful if account had balance, eitherwise 'Bad proof' error should be raised
                pass

    def test_create_batch_extrinsic(self):

        balance_call = self.polkadot_substrate.compose_call(
            call_module='Balances',
            call_function='transfer',
            call_params={
                'dest': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk',
                'value': 3 * 10 ** 3
            }
        )

        call = self.polkadot_substrate.compose_call(
            call_module='Utility',
            call_function='batch',
            call_params={
                'calls': [balance_call, balance_call]
            }
        )

        extrinsic = self.polkadot_substrate.create_signed_extrinsic(call=call, keypair=self.keypair, era={'period': 64})

        # Decode extrinsic again as test
        extrinsic.decode(extrinsic.data)

        self.assertEqual('Utility', extrinsic.value['call']['call_module'])
        self.assertEqual('batch', extrinsic.value['call']['call_function'])

    def test_create_multisig_extrinsic(self):

        call = self.kusama_substrate.compose_call(
            call_module='Balances',
            call_function='transfer',
            call_params={
                'dest': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk',
                'value': 3 * 10 ** 3
            }
        )

        keypair_alice = Keypair.create_from_uri('//Alice', ss58_format=self.polkadot_substrate.ss58_format)
        keypair_bob = Keypair.create_from_uri('//Bob', ss58_format=self.polkadot_substrate.ss58_format)
        keypair_charlie = Keypair.create_from_uri('//Charlie', ss58_format=self.polkadot_substrate.ss58_format)

        multisig_account = self.kusama_substrate.generate_multisig_account(
            signatories=[
                keypair_alice.ss58_address,
                keypair_bob.ss58_address,
                keypair_charlie.ss58_address
            ],
            threshold=2
        )

        extrinsic = self.kusama_substrate.create_multisig_extrinsic(call, self.keypair, multisig_account, era={'period': 64})

        # Decode extrinsic again as test
        extrinsic.decode(extrinsic.data)

        self.assertEqual('Multisig', extrinsic.value['call']['call_module'])
        self.assertEqual('approve_as_multi', extrinsic.value['call']['call_function'])

    def test_create_unsigned_extrinsic(self):

        call = self.kusama_substrate.compose_call(
            call_module='Timestamp',
            call_function='set',
            call_params={
                'now': 1602857508000,
            }
        )

        extrinsic = self.kusama_substrate.create_unsigned_extrinsic(call)
        self.assertEqual(str(extrinsic.data), '0x280402000ba09cc0317501')

    def test_payment_info(self):
        keypair = Keypair(ss58_address="EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk")

        call = self.kusama_substrate.compose_call(
            call_module='Balances',
            call_function='transfer',
            call_params={
                'dest': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk',
                'value': 2000
            }
        )
        payment_info = self.kusama_substrate.get_payment_info(call=call, keypair=keypair)

        self.assertIn('class', payment_info)
        self.assertIn('partialFee', payment_info)
        self.assertIn('weight', payment_info)

        self.assertGreater(payment_info['partialFee'], 0)

    def test_generate_signature_payload_lte_256_bytes(self):

        call = self.kusama_substrate.compose_call(
            call_module='System',
            call_function='remark',
            call_params={
                'remark': '0x' + ('01' * 177)
            }
        )

        signature_payload = self.kusama_substrate.generate_signature_payload(call=call)

        self.assertEqual(signature_payload.length, 256)

    def test_generate_signature_payload_gt_256_bytes(self):

        call = self.kusama_substrate.compose_call(
            call_module='System',
            call_function='remark',
            call_params={
                'remark': '0x' + ('01' * 178)
            }
        )

        signature_payload = self.kusama_substrate.generate_signature_payload(call=call)

        self.assertEqual(signature_payload.length, 32)

    def test_create_extrinsic_bytes_signature(self):
        # Create balance transfer call
        call = self.kusama_substrate.compose_call(
            call_module='Balances',
            call_function='transfer',
            call_params={
                'dest': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk',
                'value': 3 * 10 ** 3
            }
        )

        signature_hex = '01741d037f6ea0c5269c6d78cde9505178ee928bb1077db49c684f9d1cad430e767e09808bc556ea2962a7b21a' \
                        'ada78b3aaf63a8b41e035acfdb0f650634863f83'

        extrinsic = self.kusama_substrate.create_signed_extrinsic(
            call=call, keypair=self.keypair, signature=f'0x{signature_hex}'
        )

        self.assertEqual(extrinsic.value['signature']['Sr25519'], f'0x{signature_hex[2:]}')

        extrinsic = self.kusama_substrate.create_signed_extrinsic(
            call=call, keypair=self.keypair, signature=bytes.fromhex(signature_hex)
        )

        self.assertEqual(extrinsic.value['signature']['Sr25519'], f'0x{signature_hex[2:]}')

    def test_check_extrinsic_receipt(self):
        result = ExtrinsicReceipt(
            substrate=self.kusama_substrate,
            extrinsic_hash="0x5bcb59fdfc2ba852dabf31447b84764df85c8f64073757ea800f25b48e63ebd2",
            block_hash="0x8dae706d0f4882a7db484e708e27d9363a3adfa53baaac8b58c30f7c519a2520"
        )

        self.assertTrue(result.is_success)

        result = ExtrinsicReceipt(
            substrate=self.kusama_substrate,
            extrinsic_hash="0x43ef739a8e4782e306908e710f333e65843fb35a57ec2a19df21cdc12258fbd8",
            block_hash="0x8ab60dacd8535d948a755f72a9e09274d17f00693bbbdb55fa898db60a9ce580"
        )

        self.assertTrue(result.is_success)

    def test_extrinsic_receipt_by_identifier(self):
        receipt = self.polkadot_substrate.retrieve_extrinsic_by_identifier("11529741-2")
        self.assertEqual(receipt.extrinsic.value['address'], '16amaf1FuEFHstAoKjQiq8ZLWR6zjsYTvAiyHupA8DJ9Mhwu')
        self.assertEqual(
            receipt.extrinsic.value['call']['call_args'][0]['value'], '1pg9GBY7Xm5wZSNBr9BrmS978f5g33PGt45PyjiwKpU4hZG'
        )

    def test_extrinsic_receipt_by_hash(self):
        receipt = self.polkadot_substrate.retrieve_extrinsic_by_hash(
            block_hash="0x9f726d0ba1e7622c3df8c9f1eacdd1df03deabfc1d788623fc47f494e18c3f38",
            extrinsic_hash="0xe1ca67a62655d45863be7bf87004a79351bf4a798ba92f666d3a8152bb769d0c"
        )
        self.assertEqual(receipt.extrinsic.value['address'], '16amaf1FuEFHstAoKjQiq8ZLWR6zjsYTvAiyHupA8DJ9Mhwu')
        self.assertEqual(
            receipt.extrinsic.value['call']['call_args'][0]['value'], '1pg9GBY7Xm5wZSNBr9BrmS978f5g33PGt45PyjiwKpU4hZG'
        )

    def test_check_extrinsic_failed_result(self):
        result = ExtrinsicReceipt(
            substrate=self.kusama_substrate,
            extrinsic_hash="0xa5f2b9f4b8ea9f357780dd49010c99708f580a02624e4500af24b20b92773100",
            block_hash="0x4b459839cc0b8c807061b5bfc68ca78b2039296174ed0a7754a70b84b287181e"
        )

        self.assertFalse(result.is_success)

    def test_check_extrinsic_receipt_failed_scaleinfo(self):
        receipt = self.kusama_substrate.retrieve_extrinsic_by_identifier("15237367-80")
        self.assertFalse(receipt.is_success)

    def test_check_extrinsic_failed_error_message(self):
        result = ExtrinsicReceipt(
            substrate=self.kusama_substrate,
            extrinsic_hash="0xa5f2b9f4b8ea9f357780dd49010c99708f580a02624e4500af24b20b92773100",
            block_hash="0x4b459839cc0b8c807061b5bfc68ca78b2039296174ed0a7754a70b84b287181e"
        )

        self.assertEqual(result.error_message['name'], 'LiquidityRestrictions')

    def test_check_extrinsic_failed_error_message2(self):
        result = ExtrinsicReceipt(
            substrate=self.kusama_substrate,
            extrinsic_hash="0x6147478693eb1ccbe1967e9327c5db093daf5f87bbf6822b4bd8d3dc3bf4e356",
            block_hash="0x402f22856baf7aaca9510c317b1c392e4d9e6133aabcc0c26f6c5b40dcde70a7"
        )

        self.assertEqual(result.error_message['name'], 'MustBeVoter')

    def test_check_extrinsic_failed_error_message_portable_registry(self):
        receipt = self.kusama_substrate.retrieve_extrinsic_by_identifier("11333518-4")

        self.assertFalse(receipt.is_success)
        self.assertEqual(881719000, receipt.weight)
        self.assertEqual(receipt.error_message['name'], 'InsufficientBalance')

    def test_check_extrinsic_weight_v2(self):
        receipt = self.kusama_substrate.retrieve_extrinsic_by_identifier("14963132-10")

        self.assertTrue(receipt.is_success)
        self.assertEqual({'ref_time': 153773000}, receipt.weight)

    def test_check_extrinsic_total_fee_amount(self):
        result = ExtrinsicReceipt(
            substrate=self.kusama_substrate,
            extrinsic_hash="0xa5f2b9f4b8ea9f357780dd49010c99708f580a02624e4500af24b20b92773100",
            block_hash="0x4b459839cc0b8c807061b5bfc68ca78b2039296174ed0a7754a70b84b287181e"
        )

        self.assertEqual(2583332366, result.total_fee_amount)

    def test_check_extrinsic_total_fee_amount_portable_registry(self):
        result = ExtrinsicReceipt(
            substrate=self.kusama_substrate,
            extrinsic_hash="0x5937b3fc03ffc62c84d536c3f1949e030b61ca5c680bfd237726e55a75840d1d",
            block_hash="0x9d693c4fa4d54893bd6b0916843fcb5b7380f43cbea5c462be9213f536fd9a49"
        )
        self.assertTrue(result.is_success)
        self.assertEqual(161331753, result.total_fee_amount)

    def test_check_extrinsic_total_fee_amount2(self):
        result = ExtrinsicReceipt(
            substrate=self.kusama_substrate,
            extrinsic_hash="0x7347df791b8e47a5eba29c2123783cac638acbe63b4a99024eade4e7805d7ab7",
            block_hash="0xffbf45b4dfa1be1929b519d5bf6558b2c972ea2e0fe24b623111b238cf67e095"
        )

        self.assertEqual(2749998966, result.total_fee_amount)

    def test_check_extrinsic_total_fee_amount_new_event(self):
        receipt = self.polkadot_substrate.retrieve_extrinsic_by_identifier("12031188-2")

        self.assertEqual(156673273, receipt.total_fee_amount)

    def test_check_failed_extrinsic_weight(self):
        result = ExtrinsicReceipt(
            substrate=self.kusama_substrate,
            extrinsic_hash="0xa5f2b9f4b8ea9f357780dd49010c99708f580a02624e4500af24b20b92773100",
            block_hash="0x4b459839cc0b8c807061b5bfc68ca78b2039296174ed0a7754a70b84b287181e"
        )

        self.assertEqual(216625000, result.weight)

    def test_check_success_extrinsic_weight(self):
        result = ExtrinsicReceipt(
            substrate=self.kusama_substrate,
            extrinsic_hash="0x5bcb59fdfc2ba852dabf31447b84764df85c8f64073757ea800f25b48e63ebd2",
            block_hash="0x8dae706d0f4882a7db484e708e27d9363a3adfa53baaac8b58c30f7c519a2520"
        )

        self.assertEqual(10000, result.weight)

    def test_check_success_extrinsic_weight2(self):
        result = ExtrinsicReceipt(
            substrate=self.kusama_substrate,
            extrinsic_hash="0x7347df791b8e47a5eba29c2123783cac638acbe63b4a99024eade4e7805d7ab7",
            block_hash="0xffbf45b4dfa1be1929b519d5bf6558b2c972ea2e0fe24b623111b238cf67e095"
        )

        self.assertEqual(252000000, result.weight)

    def test_check_success_extrinsic_weight_portable_registry(self):
        result = ExtrinsicReceipt(
            substrate=self.kusama_substrate,
            extrinsic_hash="0x5937b3fc03ffc62c84d536c3f1949e030b61ca5c680bfd237726e55a75840d1d",
            block_hash="0x9d693c4fa4d54893bd6b0916843fcb5b7380f43cbea5c462be9213f536fd9a49"
        )
        self.assertTrue(result.is_success)
        self.assertEqual(1234000, result.weight)

    def test_extrinsic_result_set_readonly_attr(self):
        result = ExtrinsicReceipt(
            substrate=self.kusama_substrate,
            extrinsic_hash="0xa5f2b9f4b8ea9f357780dd49010c99708f580a02624e4500af24b20b92773100"
        )
        with self.assertRaises(AttributeError):
            result.is_success = False

        with self.assertRaises(AttributeError):
            result.triggered_events = False

    def test_extrinsic_result_no_blockhash_check_events(self):

        result = ExtrinsicReceipt(
            substrate=self.kusama_substrate,
            extrinsic_hash="0xa5f2b9f4b8ea9f357780dd49010c99708f580a02624e4500af24b20b92773100"
        )

        with self.assertRaises(ValueError) as cm:
            result.triggered_events
        self.assertEqual('ExtrinsicReceipt can\'t retrieve events because it\'s unknown which block_hash it is '
                         'included, manually set block_hash or use `wait_for_inclusion` when sending extrinsic',
                         str(cm.exception))


if __name__ == '__main__':
    unittest.main()
