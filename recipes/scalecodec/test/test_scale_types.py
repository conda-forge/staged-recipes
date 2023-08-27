# Python SCALE Codec Library
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

import datetime
import os
import unittest

from scalecodec.types import GenericContractExecResult

from scalecodec.base import ScaleDecoder, ScaleBytes, RemainingScaleBytesNotEmptyException, \
    InvalidScaleTypeValueException, RuntimeConfiguration, RuntimeConfigurationObject
from scalecodec.types import GenericMultiAddress
from scalecodec.type_registry import load_type_registry_preset, load_type_registry_file
from scalecodec.utils.ss58 import ss58_encode, ss58_decode, ss58_decode_account_index, ss58_encode_account_index


class TestScaleTypes(unittest.TestCase):

    metadata_fixture_dict = {}
    metadata_decoder = None
    runtime_config_v14 = None
    metadata_v14_obj = None

    @classmethod
    def setUpClass(cls):
        module_path = os.path.dirname(__file__)
        cls.metadata_fixture_dict = load_type_registry_file(
            os.path.join(module_path, 'fixtures', 'metadata_hex.json')
        )
        RuntimeConfiguration().update_type_registry(load_type_registry_preset("core"))

        cls.metadata_decoder = RuntimeConfiguration().create_scale_object(
            'MetadataVersioned', data=ScaleBytes(cls.metadata_fixture_dict['V10'])
        )
        cls.metadata_decoder.decode()

        cls.runtime_config_v14 = RuntimeConfigurationObject(implements_scale_info=True)
        cls.runtime_config_v14.update_type_registry(load_type_registry_preset("core"))

        cls.metadata_v14_obj = cls.runtime_config_v14.create_scale_object(
            "MetadataVersioned", data=ScaleBytes(cls.metadata_fixture_dict['V14'])
        )
        cls.metadata_v14_obj.decode()
        cls.runtime_config_v14.add_portable_registry(cls.metadata_v14_obj)

    def setUp(self) -> None:
        RuntimeConfiguration().clear_type_registry()
        RuntimeConfiguration().update_type_registry(load_type_registry_preset("legacy"))
        RuntimeConfiguration().update_type_registry(load_type_registry_preset("kusama"))
        RuntimeConfiguration().set_active_spec_version_id(1045)

    # def test_automatic_decode(self):
    #     obj = ScaleDecoder.get_decoder_class('u16', ScaleBytes("0x2efb"))
    #     self.assertEqual(obj.value, 64302)

    def test_multiple_decode_without_error(self):
        obj = RuntimeConfiguration().create_scale_object('u16', ScaleBytes("0x2efb"))
        obj.decode()
        obj.decode()
        self.assertEqual(obj.value, 64302)

    def test_value_equals_value_serialized_and_value_object(self):
        obj = RuntimeConfiguration().create_scale_object('(Compact<u32>,Compact<u32>)', ScaleBytes("0x0c00"))
        obj.decode()
        self.assertEqual(obj.value, obj.value_serialized)
        self.assertEqual(obj.value, obj.value_object)

    def test_value_object(self):
        obj = RuntimeConfiguration().create_scale_object('(Compact<u32>,Compact<u32>)', ScaleBytes("0x0c00"))
        obj.decode()
        self.assertEqual(obj.value_object[0].value_object, 3)
        self.assertEqual(obj.value_object[1].value_object, 0)

    def test_value_object_shorthand(self):
        obj = RuntimeConfiguration().create_scale_object('(Compact<u32>,Compact<u32>)', ScaleBytes("0x0c00"))
        obj.decode()
        self.assertEqual(obj[0], 3)
        self.assertEqual(obj[1], 0)

    def test_compact_u32(self):
        obj = RuntimeConfiguration().create_scale_object('Compact<u32>', ScaleBytes("0x02093d00"))
        obj.decode()
        self.assertEqual(obj.value, 1000000)

    def test_compact_u32_1byte(self):
        obj = RuntimeConfiguration().create_scale_object('Compact<u32>', ScaleBytes("0x18"))
        obj.decode()
        self.assertEqual(obj.value, 6)

    def test_compact_u32_remaining_bytes(self):
        obj = RuntimeConfiguration().create_scale_object('Compact<u32>', ScaleBytes("0x02093d0001"))
        self.assertRaises(RemainingScaleBytesNotEmptyException, obj.decode)

    def test_compact_u32_invalid(self):
        obj = RuntimeConfiguration().create_scale_object('Compact<u32>', ScaleBytes("0x"))
        self.assertRaises(InvalidScaleTypeValueException, obj.decode)

    def test_u16(self):
        obj = RuntimeConfiguration().create_scale_object('u16', ScaleBytes("0x2efb"))
        obj.decode()
        self.assertEqual(obj.value, 64302)

    def test_i16(self):
        obj = RuntimeConfiguration().create_scale_object('i16', ScaleBytes("0x2efb"))
        obj.decode()
        self.assertEqual(obj.value, -1234)

    def test_f64(self):
        obj = RuntimeConfiguration().create_scale_object('f64', ScaleBytes("0x0000000000000080"))
        obj.decode()
        self.assertEqual(obj.value, -0.0)

    def test_f32(self):
        obj = RuntimeConfiguration().create_scale_object('f32', ScaleBytes("0x00000080"))
        obj.decode()
        self.assertEqual(obj.value, -0.0)

    def test_compact_bool_true(self):
        obj = RuntimeConfiguration().create_scale_object('bool', ScaleBytes("0x01"))
        obj.decode()
        self.assertEqual(obj.value, True)

    def test_compact_bool_false(self):
        obj = RuntimeConfiguration().create_scale_object('bool', ScaleBytes("0x00"))
        obj.decode()
        self.assertEqual(obj.value, False)

    def test_compact_bool_invalid(self):
        obj = RuntimeConfiguration().create_scale_object('bool', ScaleBytes("0x02"))
        self.assertRaises(InvalidScaleTypeValueException, obj.decode)

    def test_string(self):
        obj = RuntimeConfiguration().create_scale_object('String', ScaleBytes("0x1054657374"))
        obj.decode()
        self.assertEqual(str(obj), "Test")

        data = obj.encode("Test")

        self.assertEqual("0x1054657374", data.to_hex())

    def test_string_multibyte_chars(self):
        obj = RuntimeConfiguration().create_scale_object('String')

        data = obj.encode('µ')
        self.assertEqual('0x08c2b5', data.to_hex())

        obj.decode()
        self.assertEqual(str(obj), "µ")

    def test_vec_accountid(self):
        obj = RuntimeConfiguration().create_scale_object(
            'Vec<AccountId>',
            ScaleBytes("0x0865d2273adeb04478658e183dc5edf41f1d86e42255442af62e72dbf1e6c0b97765d2273adeb04478658e183dc5edf41f1d86e42255442af62e72dbf1e6c0b977")
        )
        obj.decode()
        self.assertListEqual(obj.value, [
            '0x65d2273adeb04478658e183dc5edf41f1d86e42255442af62e72dbf1e6c0b977',
            '0x65d2273adeb04478658e183dc5edf41f1d86e42255442af62e72dbf1e6c0b977'
        ])

    def test_bounded_vec_encode(self):
        obj = RuntimeConfiguration().create_scale_object('BoundedVec<Hash, maxproposals>')
        value = obj.encode(['0xe1781813275653a970b4260298b3858b36d38e072256dad674f7c786a0cae236'])
        self.assertEqual(str(value), '0x04e1781813275653a970b4260298b3858b36d38e072256dad674f7c786a0cae236')

        obj = RuntimeConfiguration().create_scale_object('BoundedVec<Option<RegistrarInfo<BalanceOf, AccountId>>,5>')
        self.assertEqual(obj.sub_type, 'Option<RegistrarInfo<BalanceOf, AccountId>>')

        value = obj.encode([None, None])
        self.assertEqual(str(value), '0x080000')

    def test_bounded_vec_decode(self):
        obj = RuntimeConfiguration().create_scale_object(
            'BoundedVec<Hash, maxproposals>',
            data=ScaleBytes('0x04e1781813275653a970b4260298b3858b36d38e072256dad674f7c786a0cae236')
        )
        self.assertEqual(obj.decode(), ['0xe1781813275653a970b4260298b3858b36d38e072256dad674f7c786a0cae236'])

        obj = RuntimeConfiguration().create_scale_object(
            'BoundedVec<Option<RegistrarInfo<BalanceOf, AccountId>>,5>', data=ScaleBytes('0x080000')
        )
        self.assertEqual([None, None], obj.decode())

    def test_validatorprefs_struct(self):
        obj = RuntimeConfiguration().create_scale_object('ValidatorPrefsTo145', ScaleBytes("0x0c00"))
        obj.decode()
        self.assertEqual(obj.value, {'unstake_threshold': 3, 'validator_payment': 0})

    def test_tuple(self):
        obj = RuntimeConfiguration().create_scale_object('(Compact<u32>,Compact<u32>)', ScaleBytes("0x0c00"))
        obj.decode()
        self.assertEqual(obj.value, (3, 0))

    def test_address(self):
        obj = RuntimeConfiguration().create_scale_object(
            'Address',
            ScaleBytes("0xff1fa9d1bd1db014b65872ee20aee4fd4d3a942d95d3357f463ea6c799130b6318")
        )
        obj.decode()
        self.assertEqual(obj.value, '1fa9d1bd1db014b65872ee20aee4fd4d3a942d95d3357f463ea6c799130b6318')

    def test_moment(self):
        obj = RuntimeConfiguration().create_scale_object('Compact<Moment>', ScaleBytes("0x03d68b655c"))
        obj.decode()
        self.assertEqual(obj.value, 1550158806)

    def test_moment_v14(self):
        obj = self.runtime_config_v14.create_scale_object(
            'scale_info::132', ScaleBytes("0x03d68b655c"), metadata=self.metadata_v14_obj
        )
        obj.decode()
        self.assertEqual(obj.value, 1550158806)

    def test_balance(self):
        obj = RuntimeConfiguration().create_scale_object('Compact<Balance>', ScaleBytes("0x130080cd103d71bc22"))
        obj.decode()
        self.assertEqual(obj.value, 2503000000000000000)

    def test_type_registry(self):
        # Example type SpecificTestType only define in type registry 'default'
        self.assertRaises(NotImplementedError, RuntimeConfiguration().create_scale_object, 'SpecificTestType', ScaleBytes("0x01000000"))

        RuntimeConfiguration().update_type_registry(load_type_registry_preset("test"))

        obj = RuntimeConfiguration().create_scale_object('SpecificTestType', ScaleBytes("0x06000000"))
        obj.decode()
        self.assertEqual(obj.value, 6)

    def test_type_registry_overloading(self):
        # Type BlockNumber defined as U32 in type registry 'kusama'
        RuntimeConfiguration().update_type_registry(load_type_registry_preset("kusama"))

        obj = RuntimeConfiguration().create_scale_object('BlockNumber', ScaleBytes("0x0000000000000001"))
        self.assertRaises(RemainingScaleBytesNotEmptyException, obj.decode)

        # Type BlockNumber changed to U64 in type registry 'test'
        RuntimeConfiguration().update_type_registry(load_type_registry_preset("test"))

        obj = RuntimeConfiguration().create_scale_object('BlockNumber', ScaleBytes("0x0000000000000001"))
        obj.decode()
        self.assertEqual(obj.value, 72057594037927936)

    def test_unknown_decoder_class(self):
        self.assertRaises(NotImplementedError, RuntimeConfiguration().create_scale_object, 'UnknownType123', ScaleBytes("0x0c00"))

    def test_unknown_dynamic_type(self):
        RuntimeConfiguration().update_type_registry(load_type_registry_preset("legacy"))

        # Create set type with u32
        self.assertRaises(NotImplementedError, RuntimeConfiguration().update_type_registry, {
            "types": {
                "UnknownType": {
                    "type": "unknown",
                    "value_a": "u32",
                    "value_b": {
                        "Value1": 1,
                        "Value2": 2
                    }
                }
            }
        })

    def test_dynamic_set(self):
        RuntimeConfiguration().update_type_registry(load_type_registry_preset("legacy"))

        obj = RuntimeConfiguration().create_scale_object('WithdrawReasons', ScaleBytes("0x0100000000000000"))
        obj.decode()

        self.assertEqual(obj.value, ["TransactionPayment"])

        obj = RuntimeConfiguration().create_scale_object('WithdrawReasons', ScaleBytes("0x0300000000000000"))
        obj.decode()

        self.assertEqual(obj.value, ["TransactionPayment", "Transfer"])

        obj = RuntimeConfiguration().create_scale_object('WithdrawReasons', ScaleBytes("0x1600000000000000"))
        obj.decode()

        self.assertEqual(obj.value, ["Transfer", "Reserve", "Tip"])

    def test_set_value_type_u32(self):
        RuntimeConfiguration().update_type_registry(load_type_registry_preset("legacy"))

        # Create set type with u32
        RuntimeConfiguration().update_type_registry({
            "types": {
                "CustomU32Set": {
                    "type": "set",
                    "value_type": "u32",
                    "value_list": {
                        "Value1": 1,
                        "Value2": 2,
                        "Value3": 4,
                        "Value4": 8,
                        "Value5": 16
                    }
                }
            }
        })

        obj = RuntimeConfiguration().create_scale_object('CustomU32Set', ScaleBytes("0x0100000000000000"))
        self.assertRaises(RemainingScaleBytesNotEmptyException, obj.decode)

        obj = RuntimeConfiguration().create_scale_object('CustomU32Set', ScaleBytes("0x01000000"))
        obj.decode()

        self.assertEqual(obj.value, ["Value1"])

        obj = RuntimeConfiguration().create_scale_object('CustomU32Set', ScaleBytes("0x03000000"))
        obj.decode()

        self.assertEqual(obj.value, ["Value1", "Value2"])

        obj = RuntimeConfiguration().create_scale_object('CustomU32Set', ScaleBytes("0x16000000"))
        obj.decode()

        self.assertEqual(obj.value, ["Value2", "Value3", "Value5"])

    def test_box_call(self):
        RuntimeConfiguration().update_type_registry(load_type_registry_preset("legacy"))

        scale_value = ScaleBytes("0x0400006e57561de4b4e63f0af8bf336008252a9597e5cdcb7622c72de4ff39731c5402070010a5d4e8")

        obj = RuntimeConfiguration().create_scale_object('Box<Call>', scale_value, metadata=self.metadata_decoder)
        value = obj.decode()

        self.assertEqual(value['call_function'], 'transfer')
        self.assertEqual(value['call_module'], 'Balances')
        self.assertEqual(value['call_args'][0]['value'], '0x6e57561de4b4e63f0af8bf336008252a9597e5cdcb7622c72de4ff39731c5402')
        self.assertEqual(value['call_args'][1]['value'], 1000000000000)

    def test_parse_subtype(self):
        RuntimeConfiguration().update_type_registry(load_type_registry_preset("legacy"))

        obj = RuntimeConfiguration().create_scale_object('(BalanceOf, Vec<(AccountId, Data)>)')

        self.assertEqual(obj.type_mapping[0], "BalanceOf")
        self.assertEqual(obj.type_mapping[1], "Vec<(AccountId, Data)>")

        obj = RuntimeConfiguration().create_scale_object('Vec<UncleEntryItem<BlockNumber, Hash, AccountId>>')

        self.assertEqual(obj.sub_type, "UncleEntryItem<BlockNumber, Hash, AccountId>")

    def test_dynamic_fixed_array_type_decode(self):
        obj = RuntimeConfiguration().create_scale_object('[u32; 1]', data=ScaleBytes("0x01000000"))
        self.assertEqual([1], obj.decode())

        obj = RuntimeConfiguration().create_scale_object('[u32; 3]', data=ScaleBytes("0x010000000200000003000000"))
        self.assertEqual([1, 2, 3], obj.decode())

        obj = RuntimeConfiguration().create_scale_object('[u32; 0]', data=ScaleBytes(bytes()))
        self.assertEqual([], obj.decode())

    def test_dynamic_fixed_array_type_decode_u8(self):
        obj = RuntimeConfiguration().create_scale_object('[u8; 65]', data=ScaleBytes("0xc42b82d02bce3202f6a05d4b06d1ad46963d3be36fd0528bbe90e7f7a4e5fcd38d14234b1c9fcee920d76cfcf43b4ed5dd718e357c2bc1aae3a642975207e67f01"))
        self.assertEqual('0xc42b82d02bce3202f6a05d4b06d1ad46963d3be36fd0528bbe90e7f7a4e5fcd38d14234b1c9fcee920d76cfcf43b4ed5dd718e357c2bc1aae3a642975207e67f01', obj.decode())

    def test_dynamic_fixed_array_type_encode_u8(self):
        obj = RuntimeConfiguration().create_scale_object('[u8; 2]')
        self.assertEqual('0x0102', str(obj.encode('0x0102')))
        self.assertEqual('0x0102', str(obj.encode(b'\x01\x02')))
        self.assertEqual('0x0102', str(obj.encode([1, 2])))

    def test_dynamic_fixed_array_type_encode(self):
        obj = RuntimeConfiguration().create_scale_object('[u32; 1]')
        self.assertEqual('0x0100000002000000', str(obj.encode([1, 2])))

        obj = RuntimeConfiguration().create_scale_object('[u8; 3]')
        self.assertEqual('0x010203', str(obj.encode('0x010203')))

    def test_invalid_fixed_array_type_encode(self):
        obj = RuntimeConfiguration().create_scale_object('[u8; 3]')
        self.assertRaises(ValueError, obj.encode, '0x0102')

        obj = RuntimeConfiguration().create_scale_object('[u32; 3]')
        self.assertRaises(ValueError, obj.encode, '0x0102')

    def test_custom_tuple(self):
        obj = RuntimeConfiguration().create_scale_object('(u8,u8)', ScaleBytes("0x0102"))
        self.assertEqual((1, 2), obj.decode())

    def test_create_multi_sig_address(self):
        MultiAccountId = RuntimeConfiguration().get_decoder_class("MultiAccountId")

        multi_sig_account = MultiAccountId.create_from_account_list(
            ["CdVuGwX71W4oRbXHsLuLQxNPns23rnSSiZwZPN4etWf6XYo",
             "J9aQobenjZjwWtU2MsnYdGomvcYbgauCnBeb8xGrcqznvJc",
             "HvqnQxDQbi3LL2URh7WQfcmi8b2ZWfBhu7TEDmyyn5VK8e2"], 2)

        multi_sig_address = ss58_encode(multi_sig_account.value.replace('0x', ''), 2)

        self.assertEqual(multi_sig_address, "HFXXfXavDuKhLLBhFQTat2aaRQ5CMMw9mwswHzWi76m6iLt")

    def test_opaque_call(self):

        opaque_call_obj = RuntimeConfiguration().create_scale_object('OpaqueCall', metadata=self.metadata_decoder)

        call_value = {
            'call_module': 'System',
            'call_function': 'remark',
            'call_args': {
                '_remark': '0x0123456789'
            }
        }

        scale_data = opaque_call_obj.encode(call_value)

        self.assertEqual(str(scale_data), '0x200001140123456789')

        opaque_call_obj = RuntimeConfiguration().create_scale_object('OpaqueCall', data=scale_data, metadata=self.metadata_decoder)

        value = opaque_call_obj.decode()

        self.assertEqual(value['call_function'], 'remark')
        self.assertEqual(value['call_module'], 'System')
        self.assertEqual(value['call_args'][0]['value'], '0x0123456789')
        self.assertEqual(value['call_args'][0]['name'], '_remark')

    def test_wrapped_opaque_decode_success(self):
        opaque_hex = '0x1805000022db73'
        wrapped_obj = self.runtime_config_v14.create_scale_object(
            type_string="WrapperKeepOpaque",
            metadata=self.metadata_v14_obj
        )
        wrapped_obj.type_mapping = ("Compact<u32>", "Call")
        wrapped_obj.decode(ScaleBytes(opaque_hex))
        self.assertEqual("Indices", wrapped_obj.value["call_module"])

    def test_wrapped_opaque_decode_fail(self):
        opaque_hex = '0x180a000022db73'
        wrapped_obj = self.runtime_config_v14.create_scale_object(
            type_string="WrapperKeepOpaque",
            metadata=self.metadata_v14_obj
        )
        wrapped_obj.type_mapping = ("Compact<u32>", "Call")
        wrapped_obj.decode(ScaleBytes(opaque_hex))
        self.assertEqual(
            "0x0a000022db73",
            wrapped_obj.value
        )

    def test_wrapped_opaque_decode_incorrect(self):
        opaque_hex = '0xa405000022db73'
        wrapped_obj = self.runtime_config_v14.create_scale_object(
            type_string="WrapperKeepOpaque",
            metadata=self.metadata_v14_obj
        )
        with self.assertRaises(ValueError):
            wrapped_obj.decode(ScaleBytes(opaque_hex))

    def test_wrapped_opaque_encode(self):
        wrapped_obj = self.runtime_config_v14.create_scale_object(
            type_string="WrapperKeepOpaque",
            metadata=self.metadata_v14_obj
        )
        wrapped_obj.type_mapping = ("Compact<u32>", "Call")

        wrapped_obj.encode({
            'call_function': 'claim',
            'call_module': 'Indices',
            'call_args': {'index': 1943740928}
        })

        self.assertEqual(
            "0x1805000022db73",
            wrapped_obj.data.to_hex()
        )

    def test_era_immortal(self):
        obj = RuntimeConfiguration().create_scale_object('Era', ScaleBytes('0x00'))
        obj.decode()
        self.assertEqual(obj.value, '00')
        self.assertIsNone(obj.period)
        self.assertIsNone(obj.phase)

    def test_era_mortal(self):
        obj = RuntimeConfiguration().create_scale_object('Era', ScaleBytes('0x4e9c'))
        obj.decode()
        self.assertTupleEqual(obj.value, (32768, 20000))
        self.assertEqual(obj.period, 32768)
        self.assertEqual(obj.phase, 20000)

        obj = RuntimeConfiguration().create_scale_object('Era', ScaleBytes('0xc503'))
        obj.decode()
        self.assertTupleEqual(obj.value, (64, 60))
        self.assertEqual(obj.period, 64)
        self.assertEqual(obj.phase, 60)

        obj = RuntimeConfiguration().create_scale_object('Era', ScaleBytes('0x8502'))
        obj.decode()
        self.assertTupleEqual(obj.value, (64, 40))
        self.assertEqual(obj.period, 64)
        self.assertEqual(obj.phase, 40)

    def test_era_methods(self):
        obj = RuntimeConfiguration().create_scale_object('Era')
        obj.encode('00')
        self.assertTrue(obj.is_immortal())
        self.assertEqual(obj.birth(1400), 0)
        self.assertEqual(obj.death(1400), 2**64 - 1)

        obj = RuntimeConfiguration().create_scale_object('Era')
        obj.encode((256, 120))
        self.assertFalse(obj.is_immortal())
        self.assertEqual(obj.birth(1400), 1400)
        self.assertEqual(obj.birth(1410), 1400)
        self.assertEqual(obj.birth(1399), 1144)
        self.assertEqual(obj.death(1400), 1656)

    def test_era_invalid_encode(self):
        obj = RuntimeConfiguration().create_scale_object('Era')
        self.assertRaises(ValueError, obj.encode, (1, 120))
        self.assertRaises(ValueError, obj.encode, ('64', 60))
        self.assertRaises(ValueError, obj.encode, 'x')
        self.assertRaises(ValueError, obj.encode, {'phase': 2})
        self.assertRaises(ValueError, obj.encode, {'period': 2})

    def test_era_invalid_decode(self):
        obj = RuntimeConfiguration().create_scale_object('Era', ScaleBytes('0x0101'))
        self.assertRaises(ValueError, obj.decode)

    def test_multiaddress_ss58_address_as_str(self):
        obj = RuntimeConfiguration().create_scale_object('Multiaddress')
        ss58_address = "CdVuGwX71W4oRbXHsLuLQxNPns23rnSSiZwZPN4etWf6XYo"

        public_key = ss58_decode(ss58_address)

        data = obj.encode(ss58_address)
        decode_obj = RuntimeConfiguration().create_scale_object('MultiAddress', data=data)

        self.assertEqual(decode_obj.decode(), f'0x{public_key}')

    def test_multiaddress_ss58_address_as_str_runtime_config(self):

        runtime_config = RuntimeConfigurationObject(ss58_format=2)
        runtime_config.update_type_registry(load_type_registry_preset("legacy"))

        obj = RuntimeConfiguration().create_scale_object('Multiaddress', runtime_config=runtime_config)
        ss58_address = "CdVuGwX71W4oRbXHsLuLQxNPns23rnSSiZwZPN4etWf6XYo"

        data = obj.encode(ss58_address)
        decode_obj = RuntimeConfiguration().create_scale_object('MultiAddress', data=data, runtime_config=runtime_config)

        self.assertEqual(decode_obj.decode(), ss58_address)

    def test_multiaddress_ss58_index_as_str(self):
        obj = RuntimeConfiguration().create_scale_object('MultiAddress')
        ss58_address = "F7Hs"

        index_id = ss58_decode_account_index(ss58_address)

        data = obj.encode(ss58_address)
        decode_obj = RuntimeConfiguration().create_scale_object('MultiAddress', data=data)

        self.assertEqual(decode_obj.decode(), index_id)

    def test_multiaddress_account_id(self):
        # Decoding
        obj = GenericMultiAddress(ScaleBytes('0x00f6a299ecbfec56e238b5feedfb4cba567d2902af5d946eaf05e3badf05790e45'))
        obj.decode()
        self.assertEqual('0xf6a299ecbfec56e238b5feedfb4cba567d2902af5d946eaf05e3badf05790e45', obj.value)
        self.assertEqual('f6a299ecbfec56e238b5feedfb4cba567d2902af5d946eaf05e3badf05790e45', obj.account_id)

        # Encoding
        self.assertEqual(
            ScaleBytes('0x00f6a299ecbfec56e238b5feedfb4cba567d2902af5d946eaf05e3badf05790e45'),
            obj.encode('0xf6a299ecbfec56e238b5feedfb4cba567d2902af5d946eaf05e3badf05790e45')
        )
        self.assertEqual(
            ScaleBytes('0x00f6a299ecbfec56e238b5feedfb4cba567d2902af5d946eaf05e3badf05790e45'),
            obj.encode({'Id': '0xf6a299ecbfec56e238b5feedfb4cba567d2902af5d946eaf05e3badf05790e45'})
        )

    def test_multiaddress_index(self):
        # Decoding
        obj = GenericMultiAddress(data=ScaleBytes('0x0104'))
        obj.decode()
        self.assertEqual(1, obj.value)
        self.assertEqual(None, obj.account_id)
        self.assertEqual(1, obj.account_index)

        # Encoding
        self.assertEqual(ScaleBytes('0x0104'), obj.encode(1))
        self.assertEqual(ScaleBytes('0x0104'), obj.encode({'Index': 1}))
        self.assertEqual(ScaleBytes('0x0104'), obj.encode('F7NZ'))

    def test_multiaddress_address20(self):
        obj = GenericMultiAddress(data=ScaleBytes('0x0467f89207abe6e1b093befd84a48f033137659292'))
        obj.decode()
        self.assertEqual({'Address20': '0x67f89207abe6e1b093befd84a48f033137659292'}, obj.value)
        self.assertEqual('67f89207abe6e1b093befd84a48f033137659292000000000000000000000000', obj.account_id)

    def test_multiaddress_address32(self):
        obj = GenericMultiAddress(ScaleBytes('0x03f6a299ecbfec56e238b5feedfb4cba567d2902af5d946eaf05e3badf05790e45'))
        obj.decode()
        self.assertEqual({'Address32': '0xf6a299ecbfec56e238b5feedfb4cba567d2902af5d946eaf05e3badf05790e45'}, obj.value)
        self.assertEqual('f6a299ecbfec56e238b5feedfb4cba567d2902af5d946eaf05e3badf05790e45', obj.account_id)

        # Encoding
        self.assertEqual(
            ScaleBytes('0x03f6a299ecbfec56e238b5feedfb4cba567d2902af5d946eaf05e3badf05790e45'),
            obj.encode({'Address32': '0xf6a299ecbfec56e238b5feedfb4cba567d2902af5d946eaf05e3badf05790e45'})
        )

    def test_multiaddress_bytes_cap(self):
        # Test decoding
        obj = GenericMultiAddress(data=ScaleBytes(
            '0x02b4111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111'
        ))
        obj.decode()
        self.assertEqual(
            {'Raw': '0x111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111'},
            obj.value
        )
        self.assertEqual('1111111111111111111111111111111111111111111111111111111111111111', obj.account_id)

        # Test encoding
        self.assertEqual(
            ScaleBytes(
                '0x02b4111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111'
            ),
            obj.encode(
                {'Raw': '0x111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111'}
            )
        )

        with self.assertRaises(NotImplementedError):
            obj.encode('0x111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111')

    def test_multiaddress_bytes_pad(self):
        # Test decoding
        obj = GenericMultiAddress(data=ScaleBytes(
            '0x02081234'
        ))
        obj.decode()
        self.assertEqual(
            {'Raw': '0x1234'},
            obj.value
        )
        self.assertEqual('1234000000000000000000000000000000000000000000000000000000000000', obj.account_id)

        # Test encoding
        self.assertEqual(
            ScaleBytes(
                '0x02081234'
            ),
            obj.encode(
                {'Raw': '0x1234'}
            )
        )

        with self.assertRaises(NotImplementedError):
            obj.encode('0x1234')

    def test_ss58_encode_index(self):
        self.assertEqual(ss58_encode_account_index(0), 'F7Hs')

    def test_bitvec_decode(self):
        obj = RuntimeConfiguration().create_scale_object('BitVec', ScaleBytes('0x0c07'))
        obj.decode()
        self.assertEqual(obj.value, '0b111')

    def test_bitvec_decode_size2(self):
        obj = RuntimeConfiguration().create_scale_object('BitVec', ScaleBytes('0x0803'))
        obj.decode()
        self.assertEqual(obj.value, '0b11')

    def test_bitvec_decode_size_2bytes(self):
        obj = RuntimeConfiguration().create_scale_object('BitVec', ScaleBytes('0x28fd02'))
        obj.decode()
        self.assertEqual(obj.value, '0b1011111101')

    def test_bitvec_encode_list(self):
        obj = RuntimeConfiguration().create_scale_object('BitVec')
        data = obj.encode([True, True, True])
        self.assertEqual(data.to_hex(), '0x0c07')

    def test_bitvec_encode_list2(self):
        obj = RuntimeConfiguration().create_scale_object('BitVec')
        data = obj.encode([True, False])
        self.assertEqual(data.to_hex(), '0x0802')

    def test_bitvec_encode_list3(self):
        obj = RuntimeConfiguration().create_scale_object('BitVec')
        data = obj.encode([False, True])
        self.assertEqual(data.to_hex(), '0x0401')

    def test_bitvec_encode_list4(self):
        obj = RuntimeConfiguration().create_scale_object('BitVec')
        data = obj.encode([True, False, False, True, True, True, True, True, False, True])
        self.assertEqual(data.to_hex(), '0x287d02')

    def test_bitvec_encode_bin_str(self):
        obj = RuntimeConfiguration().create_scale_object('BitVec')
        data = obj.encode('0b00000111')
        self.assertEqual(data.to_hex(), '0x0c07')

    def test_bitvec_encode_bin_str2(self):
        obj = RuntimeConfiguration().create_scale_object('BitVec')
        data = obj.encode('0b00000010')
        self.assertEqual(data.to_hex(), '0x0802')

    def test_bitvec_encode_bin_str3(self):
        obj = RuntimeConfiguration().create_scale_object('BitVec')
        data = obj.encode('0b00000001')
        self.assertEqual(data.to_hex(), '0x0401')

    def test_bitvec_encode_bin_str4(self):
        obj = RuntimeConfiguration().create_scale_object('BitVec')
        data = obj.encode('0b00000010_01111101')
        self.assertEqual(data.to_hex(), '0x287d02')

    def test_bitvec_encode_int(self):
        obj = RuntimeConfiguration().create_scale_object('BitVec')
        data = obj.encode(0b00000111)
        self.assertEqual(data.to_hex(), '0x0c07')

    def test_bitvec_encode_int2(self):
        obj = RuntimeConfiguration().create_scale_object('BitVec')
        data = obj.encode(0b00000010)
        self.assertEqual(data.to_hex(), '0x0802')

    def test_bitvec_encode_int3(self):
        obj = RuntimeConfiguration().create_scale_object('BitVec')
        data = obj.encode(0b00000001)
        self.assertEqual(data.to_hex(), '0x0401')

    def test_bitvec_encode_int4(self):
        obj = RuntimeConfiguration().create_scale_object('BitVec')
        data = obj.encode(0b00000010_01111101)
        self.assertEqual(data.to_hex(), '0x287d02')

    def test_bitvec_encode_empty_list(self):
        obj = RuntimeConfiguration().create_scale_object('BitVec')
        data = obj.encode([])
        self.assertEqual(data.to_hex(), '0x00')

    def test_struct_with_base_class(self):
        RuntimeConfiguration().update_type_registry(load_type_registry_preset("test"))

        obj = RuntimeConfiguration().create_scale_object('StructWithoutBaseClass')
        self.assertFalse(isinstance(obj, GenericContractExecResult))

        obj = RuntimeConfiguration().create_scale_object('StructWithBaseClass')
        self.assertTrue(isinstance(obj, GenericContractExecResult))

    def test_enum_with_base_class(self):
        RuntimeConfiguration().update_type_registry(load_type_registry_preset("test"))

        obj = RuntimeConfiguration().create_scale_object('EnumWithoutBaseClass')
        self.assertFalse(isinstance(obj, GenericContractExecResult))

        obj = RuntimeConfiguration().create_scale_object('EnumWithBaseClass')
        self.assertTrue(isinstance(obj, GenericContractExecResult))

    def test_enum_with_specified_index_number(self):
        RuntimeConfiguration().update_type_registry(load_type_registry_preset("test"))

        obj = RuntimeConfiguration().create_scale_object('EnumSpecifiedIndex')

        data = obj.encode("KSM")
        self.assertEqual("0x82", data.to_hex())

        obj = RuntimeConfiguration().create_scale_object('EnumSpecifiedIndex', data=ScaleBytes("0x80"))

        self.assertEqual("KAR", obj.decode())

    def test_enum_with_named_fields(self):
        RuntimeConfiguration().update_type_registry(load_type_registry_preset("test"))

        obj = RuntimeConfiguration().create_scale_object('EnumWithNestedStruct')

        data = obj.encode({"Nested": {"a": 3, "b": 8}})

        self.assertEqual("0x010308", data.to_hex())

        value = obj.decode(data)

        self.assertEqual({"Nested": {"a": 3, "b": 8}}, value)

    def test_set_with_base_class(self):
        RuntimeConfiguration().update_type_registry(load_type_registry_preset("test"))

        obj = RuntimeConfiguration().create_scale_object('SetWithoutBaseClass')
        self.assertFalse(isinstance(obj, GenericContractExecResult))

        obj = RuntimeConfiguration().create_scale_object('SetWithBaseClass')
        self.assertTrue(isinstance(obj, GenericContractExecResult))

    def test_hashmap_encode(self):
        obj = RuntimeConfiguration().create_scale_object('HashMap<Vec<u8>, u32>')
        data = obj.encode([('1', 2), ('23', 24), ('28', 30), ('45', 80)])
        self.assertEqual(data.to_hex(), '0x10043102000000083233180000000832381e00000008343550000000')

    def test_hashmap_decode(self):
        obj = RuntimeConfiguration().create_scale_object(
            'HashMap<Vec<u8>, u32>', data=ScaleBytes("0x10043102000000083233180000000832381e00000008343550000000")
        )
        self.assertEqual([('1', 2), ('23', 24), ('28', 30), ('45', 80)], obj.decode())

    def test_btreeset_encode(self):
        obj = RuntimeConfiguration().create_scale_object('BTreeSet<u32>')
        data = obj.encode([2, 24, 30, 80])
        self.assertEqual(data.to_hex(), "0x1002000000180000001e00000050000000")

    def test_btreeset_decode(self):
        obj = RuntimeConfiguration().create_scale_object(
            'BTreeSet<u32>', data=ScaleBytes("0x1002000000180000001e00000050000000")
        )
        self.assertEqual([2, 24, 30, 80], obj.decode())

    def test_account_id_runtime_config(self):

        ss58_address = "CdVuGwX71W4oRbXHsLuLQxNPns23rnSSiZwZPN4etWf6XYo"
        public_key = '0x' + ss58_decode(ss58_address)

        runtime_config = RuntimeConfigurationObject(ss58_format=2)
        runtime_config.update_type_registry(load_type_registry_preset("legacy"))

        # Encode
        obj = RuntimeConfiguration().create_scale_object('AccountId', runtime_config=runtime_config)
        data = obj.encode(ss58_address)

        # Decode
        decode_obj = RuntimeConfiguration().create_scale_object('AccountId', data=data, runtime_config=runtime_config)
        decode_obj.decode()

        self.assertEqual(decode_obj.value, ss58_address)
        self.assertEqual(decode_obj.ss58_address, ss58_address)
        self.assertEqual(decode_obj.public_key, public_key)

    def test_generic_vote(self):
        runtime_config = RuntimeConfigurationObject(ss58_format=2)

        vote = runtime_config.create_scale_object('GenericVote')
        data = vote.encode({'aye': True, 'conviction': 'Locked2x'})

        self.assertEqual('0x82', data.to_hex())

        vote.decode(ScaleBytes('0x04'))

        self.assertEqual(vote.value, {'aye': False, 'conviction': 'Locked4x'})

    def test_raw_bytes(self):
        runtime_config = RuntimeConfigurationObject(ss58_format=2)

        raw_bytes_obj = runtime_config.create_scale_object('RawBytes')
        data = '0x01020304'

        raw_bytes_obj.decode(ScaleBytes(data))
        self.assertEqual(data, raw_bytes_obj.value)

        raw_bytes_obj.encode(data)
        self.assertEqual(ScaleBytes(data), raw_bytes_obj.data)

