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
import os
import unittest

from scalecodec.base import ScaleBytes, ScaleDecoder, RuntimeConfiguration, RuntimeConfigurationObject
from scalecodec.types import Extrinsic
from scalecodec.type_registry import load_type_registry_preset, load_type_registry_file

from test.fixtures import metadata_1045_hex, metadata_substrate_node_template


class TestScaleTypeEncoding(unittest.TestCase):

    def setUp(self) -> None:
        RuntimeConfiguration().update_type_registry(load_type_registry_preset("legacy"))
        RuntimeConfiguration().update_type_registry(load_type_registry_preset("kusama"))
        RuntimeConfiguration().set_active_spec_version_id(1045)

    @classmethod
    def setUpClass(cls):
        cls.metadata_fixture_dict = load_type_registry_file(
            os.path.join(os.path.dirname(__file__), 'fixtures', 'metadata_hex.json')
        )

        RuntimeConfiguration().clear_type_registry()
        RuntimeConfiguration().update_type_registry(load_type_registry_preset("core"))

        cls.metadata_decoder = RuntimeConfiguration().create_scale_object(
            'MetadataVersioned', data=ScaleBytes(metadata_1045_hex)
        )
        cls.metadata_decoder.decode()

        cls.runtime_config_v14 = RuntimeConfigurationObject(implements_scale_info=True)
        cls.runtime_config_v14.update_type_registry(load_type_registry_preset("core"))

        cls.metadata_v14_obj = cls.runtime_config_v14.create_scale_object(
            "MetadataVersioned", data=ScaleBytes(cls.metadata_fixture_dict['V14'])
        )
        cls.metadata_v14_obj.decode()
        cls.runtime_config_v14.add_portable_registry(cls.metadata_v14_obj)

    def test_decode_balance_transfer_payload(self):
        unsigned_payload = "0xa8040400ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409070010a5d4e8"

        extrinsic = Extrinsic(
            data=ScaleBytes(unsigned_payload),
            metadata=self.metadata_decoder
        )
        extrinsic.decode()

        # Check call module
        self.assertEqual(extrinsic['call']['call_module'].name, 'Balances')

        # Check call function
        self.assertEqual(extrinsic['call']['call_function'].name, 'transfer')

        # Check destination address for balance transfer
        self.assertEqual(extrinsic.value['call']['call_args'][0]['type'], 'LookupSource')
        self.assertEqual(extrinsic.value['call']['call_args'][0]['value'],
                         '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409')

        # Check value of balance transfer
        self.assertEqual(extrinsic.value['call']['call_args'][1]['type'], 'Compact<Balance>')
        self.assertEqual(extrinsic.value['call']['call_args'][1]['value'], 1000000000000)

    def test_encode_attestations_more_attestations_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Attestations',
            'call_function': 'more_attestations',
            'call_args': {
                '_more': {}
            }
        })

        self.assertEqual(str(payload), "0x0c041500")

    def test_encode_authorship_set_uncles_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Authorship',
            'call_function': 'set_uncles',
            'call_args': {
                'new_uncles': [
                    {
                        "parent_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
                        "number": 0,
                        "state_root": "0x0000000000000000000000000000000000000000000000000000000000000000",
                        "extrinsics_root": "0x0000000000000000000000000000000000000000000000000000000000000000",
                        "digest": {"logs": []}
                    }
                ]
            }
        })

        self.assertEqual(str(payload),
                         "0x9901040500040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")

    def test_encode_balances_force_transfer_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Balances',
            'call_function': 'force_transfer',
            'call_args': {
                'dest': '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409',
                'source': '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409',
                'value': 1000000000000
            }
        })

        self.assertEqual(str(payload),
                         "0x2d01040402ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409070010a5d4e8")

    def test_encode_balances_force_transfer_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Balances',
            'call_function': 'force_transfer',
            'call_args': {
                'dest': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk',
                'source': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk',
                'value': 1000000000000
            }
        })

        self.assertEqual(str(payload),
                         "0x2d01040402ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409070010a5d4e8")

    def test_encode_balances_set_balance_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Balances',
            'call_function': 'set_balance',
            'call_args': {
                'new_free': 1000000000000,
                'new_reserved': 2000000000000,
                'who': '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409'
            }
        })

        self.assertEqual(str(payload),
                         "0xc4040401ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409070010a5d4e80b00204aa9d101")

    def test_encode_balances_set_balance_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Balances',
            'call_function': 'set_balance',
            'call_args': {
                'new_free': 1000000000000,
                'new_reserved': 2000000000000,
                'who': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk'
            }
        })

        self.assertEqual(str(payload),
                         "0xc4040401ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409070010a5d4e80b00204aa9d101")

    def test_encode_balances_transfer_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Balances',
            'call_function': 'transfer',
            'call_args': {
                'dest': '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409',
                'value': 1000000000000
            }
        })

        self.assertEqual(str(payload),
                         "0xa8040400ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409070010a5d4e8")

    def test_encode_balance_transfer_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Balances',
            'call_function': 'transfer',
            'call_args': {
                'dest': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk',
                'value': 1000000000000
            }
        })

        self.assertEqual(str(payload),
                         "0xa8040400ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409070010a5d4e8")

    def test_encode_balances_transfer_keep_alive_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Balances',
            'call_function': 'transfer_keep_alive',
            'call_args': {
                'dest': '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409',
                'value': 1000000000000
            }
        })

        self.assertEqual(str(payload),
                         "0xa8040403ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409070010a5d4e8")

    def test_encode_balances_transfer_keep_alive_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Balances',
            'call_function': 'transfer_keep_alive',
            'call_args': {
                'dest': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk',
                'value': 1000000000000
            }
        })

        self.assertEqual(str(payload),
                         "0xa8040403ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409070010a5d4e8")

    def test_encode_claims_claim_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Claims',
            'call_function': 'claim',
            'call_args': {
                'dest': '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409',
                'ethereum_signature': '0xd7c4955996cf00953e65ec1895825b9c3894041ed8ab6bd671c456d53f5d04c13948a58a5f20c7c0d3f1e0d08c33ff590a8c681f6a9db78477ca83c8ab8711f500'
            }
        })

        self.assertEqual(str(payload),
                         "0x9101041300586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409d7c4955996cf00953e65ec1895825b9c3894041ed8ab6bd671c456d53f5d04c13948a58a5f20c7c0d3f1e0d08c33ff590a8c681f6a9db78477ca83c8ab8711f500")

    def test_encode_claims_claim_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Claims',
            'call_function': 'claim',
            'call_args': {
                'dest': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk',
                'ethereum_signature': '0xd7c4955996cf00953e65ec1895825b9c3894041ed8ab6bd671c456d53f5d04c13948a58a5f20c7c0d3f1e0d08c33ff590a8c681f6a9db78477ca83c8ab8711f500'
            }
        })

        self.assertEqual(str(payload),
                         "0x9101041300586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409d7c4955996cf00953e65ec1895825b9c3894041ed8ab6bd671c456d53f5d04c13948a58a5f20c7c0d3f1e0d08c33ff590a8c681f6a9db78477ca83c8ab8711f500")

    def test_encode_claims_mint_claim_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Claims',
            'call_function': 'mint_claim',
            'call_args': {
                'value': 1000000000000,
                'vesting_schedule': None,
                'who': '0x0123456789012345678901234567890123456789'
            }
        })

        self.assertEqual(str(payload),
                         "0xa004130101234567890123456789012345678901234567890010a5d4e8000000000000000000000000")

    def test_encode_claims_mint_claim_withvesting_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Claims',
            'call_function': 'mint_claim',
            'call_args': {
                'value': 1000000000000,
                'vesting_schedule': [2000000000000, 3000000000000, 1000000],
                'who': '0x0123456789012345678901234567890123456789'
            }
        })

        self.assertEqual(str(payload),
                         "0x310104130101234567890123456789012345678901234567890010a5d4e800000000000000000000000100204aa9d101000000000000000000000030ef7dba020000000000000000000040420f00")

    def test_encode_council_execute_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Council',
            'call_function': 'execute',
            'call_args': {
                'proposal': {
                    'call_module': 'System',
                    'call_function': 'remark',
                    'call_args': {
                        '_remark': '0x0123456789'
                    }
                }
            }
        })

        self.assertEqual(str(payload), "0x2c040e010001140123456789")

    def test_encode_council_propose_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Council',
            'call_function': 'propose',
            'call_args': {
                'proposal': {
                    'call_module': 'System',
                    'call_function': 'remark',
                    'call_args': {
                        '_remark': '0x0123456789'
                    }
                },
                'threshold': 7
            }
        })

        self.assertEqual(str(payload), "0x30040e021c0001140123456789")

    def test_encode_council_set_members_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Council',
            'call_function': 'set_members',
            'call_args': {
                'new_members': ["0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409",
                                "0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409"]
            }
        })

        self.assertEqual(str(payload),
                         "0x1101040e0008586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_council_set_members_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Council',
            'call_function': 'set_members',
            'call_args': {
                'new_members': ["EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk",
                                "EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk"]
            }
        })

        self.assertEqual(str(payload),
                         "0x1101040e0008586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_council_vote_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Council',
            'call_function': 'vote',
            'call_args': {
                'approve': True,
                'index': 1,
                'proposal': '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
            }
        })

        self.assertEqual(str(payload), "0x94040e030123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0401")

    def test_encode_democracy_cancel_queued_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Democracy',
            'call_function': 'cancel_queued',
            'call_args': {
                'which': 1
            }
        })

        self.assertEqual(str(payload), "0x1c040d0b01000000")

    def test_encode_democracy_cancel_referendum_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Democracy',
            'call_function': 'cancel_referendum',
            'call_args': {
                'ref_index': 1
            }
        })

        self.assertEqual(str(payload), "0x10040d0a04")

    def test_encode_democracy_clear_public_proposals_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Democracy',
            'call_function': 'clear_public_proposals',
            'call_args': {
            }
        })

        self.assertEqual(str(payload), "0x0c040d11")

    def test_encode_democracy_delegate_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Democracy',
            'call_function': 'delegate',
            'call_args': {
                'conviction': 'None',
                'to': '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409'
            }
        })

        self.assertEqual(str(payload), "0x90040d0f586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c40900")

    def test_encode_democracy_delegate_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Democracy',
            'call_function': 'delegate',
            'call_args': {
                'conviction': 'None',
                'to': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk'
            }
        })

        self.assertEqual(str(payload), "0x90040d0f586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c40900")

    def test_encode_democracy_delegate_withconviction_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Democracy',
            'call_function': 'delegate',
            'call_args': {
                'conviction': 'Locked5x',
                'to': '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409'
            }
        })

        self.assertEqual(str(payload), "0x90040d0f586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c40905")

    def test_encode_democracy_delegate_withconviction_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Democracy',
            'call_function': 'delegate',
            'call_args': {
                'conviction': 'Locked5x',
                'to': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk'
            }
        })

        self.assertEqual(str(payload), "0x90040d0f586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c40905")

    def test_encode_democracy_emergency_cancel_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Democracy',
            'call_function': 'emergency_cancel',
            'call_args': {
                'ref_index': 1
            }
        })

        self.assertEqual(str(payload), "0x1c040d0401000000")

    def test_encode_democracy_external_propose_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Democracy',
            'call_function': 'external_propose',
            'call_args': {
                'proposal_hash': '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
            }
        })

        self.assertEqual(str(payload), "0x8c040d050123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef")

    def test_encode_democracy_external_propose_default_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Democracy',
            'call_function': 'external_propose_default',
            'call_args': {
                'proposal_hash': '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
            }
        })

        self.assertEqual(str(payload), "0x8c040d070123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef")

    def test_encode_democracy_external_propose_majority_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Democracy',
            'call_function': 'external_propose_majority',
            'call_args': {
                'proposal_hash': '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
            }
        })

        self.assertEqual(str(payload), "0x8c040d060123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef")

    def test_encode_democracy_fast_track_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Democracy',
            'call_function': 'fast_track',
            'call_args': {
                'delay': 2000,
                'proposal_hash': '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
                'voting_period': 1000
            }
        })

        self.assertEqual(str(payload),
                         "0xac040d080123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdefe8030000d0070000")

    def test_encode_democracy_note_imminent_preimage_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Democracy',
            'call_function': 'note_imminent_preimage',
            'call_args': {
                'encoded_proposal': '0x00'
            }
        })

        self.assertEqual(str(payload), "0x14040d130400")

    def test_encode_democracy_note_preimage_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Democracy',
            'call_function': 'note_preimage',
            'call_args': {
                'encoded_proposal': '0x00'
            }
        })

        self.assertEqual(str(payload), "0x14040d120400")

    def test_encode_democracy_propose_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Democracy',
            'call_function': 'propose',
            'call_args': {
                'proposal_hash': '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
                'value': 1000000000000
            }
        })

        self.assertEqual(str(payload),
                         "0xa4040d000123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef070010a5d4e8")

    def test_encode_democracy_proxy_vote_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Democracy',
            'call_function': 'proxy_vote',
            'call_args': {
                'ref_index': 0,
                'vote': 128
            }
        })

        self.assertEqual(str(payload), "0x14040d030080")

    def test_encode_democracy_reap_preimage_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Democracy',
            'call_function': 'reap_preimage',
            'call_args': {
                'proposal_hash': '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
            }
        })

        self.assertEqual(str(payload), "0x8c040d140123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef")

    def test_encode_democracy_remove_proxy_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Democracy',
            'call_function': 'remove_proxy',
            'call_args': {
                'proxy': '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409'
            }
        })

        self.assertEqual(str(payload), "0x8c040d0e586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_democracy_remove_proxy_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Democracy',
            'call_function': 'remove_proxy',
            'call_args': {
                'proxy': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk'
            }
        })

        self.assertEqual(str(payload), "0x8c040d0e586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_democracy_resign_proxy_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Democracy',
            'call_function': 'resign_proxy',
            'call_args': {

            }
        })

        self.assertEqual(str(payload), "0x0c040d0d")

    def test_encode_democracy_second_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Democracy',
            'call_function': 'second',
            'call_args': {
                'proposal': 1
            }
        })

        self.assertEqual(str(payload), "0x10040d0104")

    def test_encode_democracy_set_proxy_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Democracy',
            'call_function': 'set_proxy',
            'call_args': {
                'proxy': '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409'
            }
        })

        self.assertEqual(str(payload), "0x8c040d0c586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_democracy_set_proxy_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Democracy',
            'call_function': 'set_proxy',
            'call_args': {
                'proxy': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk'
            }
        })

        self.assertEqual(str(payload), "0x8c040d0c586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_democracy_undelegate_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Democracy',
            'call_function': 'undelegate',
            'call_args': {

            }
        })

        self.assertEqual(str(payload), "0x0c040d10")

    def test_encode_democracy_veto_external_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Democracy',
            'call_function': 'veto_external',
            'call_args': {
                'proposal_hash': '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
            }
        })

        self.assertEqual(str(payload), "0x8c040d090123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef")

    def test_encode_democracy_vote_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Democracy',
            'call_function': 'vote',
            'call_args': {
                'ref_index': 0,
                'vote': 128
            }
        })

        self.assertEqual(str(payload), "0x14040d020080")

    def test_encode_electionsphragmen_remove_member_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'ElectionsPhragmen',
            'call_function': 'remove_member',
            'call_args': {
                'who': '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409'
            }
        })

        self.assertEqual(str(payload), "0x90041005ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_electionsphragmen_remove_member_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'ElectionsPhragmen',
            'call_function': 'remove_member',
            'call_args': {
                'who': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk'
            }
        })

        self.assertEqual(str(payload), "0x90041005ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_electionsphragmen_remove_voter_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'ElectionsPhragmen',
            'call_function': 'remove_voter',
            'call_args': {

            }
        })

        self.assertEqual(str(payload), "0x0c041001")

    def test_encode_electionsphragmen_renounce_candidacy_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'ElectionsPhragmen',
            'call_function': 'renounce_candidacy',
            'call_args': {

            }
        })

        self.assertEqual(str(payload), "0x0c041004")

    def test_encode_electionsphragmen_report_defunct_voter_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'ElectionsPhragmen',
            'call_function': 'report_defunct_voter',
            'call_args': {
                'target': '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409'
            }
        })

        self.assertEqual(str(payload), "0x90041002ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_electionsphragmen_report_defunct_voter_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'ElectionsPhragmen',
            'call_function': 'report_defunct_voter',
            'call_args': {
                'target': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk'
            }
        })

        self.assertEqual(str(payload), "0x90041002ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_electionsphragmen_submit_candidacy_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'ElectionsPhragmen',
            'call_function': 'submit_candidacy',
            'call_args': {

            }
        })

        self.assertEqual(str(payload), "0x0c041003")

    def test_encode_electionsphragmen_vote_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'ElectionsPhragmen',
            'call_function': 'vote',
            'call_args': {
                'value': 1000000000000,
                'votes': ["0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409",
                          "0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409",
                          "0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409"]
            }
        })

        self.assertEqual(str(payload),
                         "0xa9010410000c586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409070010a5d4e8")

    def test_encode_electionsphragmen_vote_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'ElectionsPhragmen',
            'call_function': 'vote',
            'call_args': {
                'value': 1000000000000,
                'votes': ["EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk",
                          "EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk",
                          "EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk"]
            }
        })

        self.assertEqual(str(payload),
                         "0xa9010410000c586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409070010a5d4e8")

    def test_encode_finalitytracker_final_hint_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'FinalityTracker',
            'call_function': 'final_hint',
            'call_args': {
                'hint': 500000
            }
        })

        self.assertEqual(str(payload), "0x1c04090082841e00")

    def test_encode_grandpa_report_misbehavior_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Grandpa',
            'call_function': 'report_misbehavior',
            'call_args': {
                '_report': '0x00'
            }
        })

        self.assertEqual(str(payload), "0x14040a000400")

    def test_encode_identity_add_registrar_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Identity',
            'call_function': 'add_registrar',
            'call_args': {
                'account': '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409'
            }
        })

        self.assertEqual(str(payload), "0x8c041900586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_identity_add_registrar_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Identity',
            'call_function': 'add_registrar',
            'call_args': {
                'account': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk'
            }
        })

        self.assertEqual(str(payload), "0x8c041900586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_identity_cancel_request_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Identity',
            'call_function': 'cancel_request',
            'call_args': {
                'reg_index': 1
            }
        })

        self.assertEqual(str(payload), "0x1c04190501000000")

    def test_encode_identity_clear_identity_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Identity',
            'call_function': 'clear_identity',
            'call_args': {

            }
        })

        self.assertEqual(str(payload), "0x0c041903")

    def test_encode_identity_kill_identity_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Identity',
            'call_function': 'kill_identity',
            'call_args': {
                'target': '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409'
            }
        })

        self.assertEqual(str(payload), "0x9004190aff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_identity_kill_identity_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Identity',
            'call_function': 'kill_identity',
            'call_args': {
                'target': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk'
            }
        })

        self.assertEqual(str(payload), "0x9004190aff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_identity_provide_judgement_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Identity',
            'call_function': 'provide_judgement',
            'call_args': {
                'judgement': {"KnownGood": None},
                'reg_index': 1,
                'target': '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409'
            }
        })

        self.assertEqual(str(payload),
                         "0x9804190904ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c40903")

    def test_encode_identity_provide_judgement_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Identity',
            'call_function': 'provide_judgement',
            'call_args': {
                'judgement': {"KnownGood": None},
                'reg_index': 1,
                'target': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk'
            }
        })

        self.assertEqual(str(payload),
                         "0x9804190904ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c40903")

    def test_encode_identity_request_judgement_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Identity',
            'call_function': 'request_judgement',
            'call_args': {
                'max_fee': 2000000000000,
                'reg_index': 1
            }
        })

        self.assertEqual(str(payload), "0x2c041904040b00204aa9d101")

    def test_encode_identity_set_account_id_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Identity',
            'call_function': 'set_account_id',
            'call_args': {
                'index': 1,
                'new': '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409'
            }
        })

        self.assertEqual(str(payload), "0x9004190704586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_identity_set_account_id_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Identity',
            'call_function': 'set_account_id',
            'call_args': {
                'index': 1,
                'new': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk'
            }
        })

        self.assertEqual(str(payload), "0x9004190704586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_identity_set_fee_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Identity',
            'call_function': 'set_fee',
            'call_args': {
                'fee': 1000000000000,
                'index': 1
            }
        })

        self.assertEqual(str(payload), "0x2804190604070010a5d4e8")

    # TODO: Unable to determine default type for {"info":6,"type":"IdentityFields"}
    def test_encode_identity_set_fields_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Identity',
            'call_function': 'set_fields',
            'call_args': {
                'fields': ['Display', 'Legal', 'Email', 'Twitter'],
                'index': 1
            }
        })

        self.assertEqual(str(payload), "0x30041908049300000000000000")

    def test_encode_identity_set_identity_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Identity',
            'call_function': 'set_identity',
            'call_args': {
                'info': {
                    "additional": [],
                    "display": {"Raw": "Test1"},
                    "legal": {"Raw": "Test2"},
                    "web": {"None": None},
                    "riot": {"Raw": "Test3"},
                    "email": {"None": None},
                    "pgp_fingerprint": None,
                    "image": {"None": None},
                    "twitter": {"None": None}
                }
            }
        })

        self.assertEqual(str(payload),
                         "0x6c041901000654657374310654657374320006546573743300000000")

    def test_encode_identity_set_subs_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Identity',
            'call_function': 'set_subs',
            'call_args': {
                'subs': [
                    ["0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409", {"None": None}],
                    ["0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409", {"Raw": "Test"}]
                ]
            }
        })

        self.assertEqual(str(payload),
                         "0x290104190208586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a8"
                         "0ac00225c40900586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c4090554657374")

    def test_encode_identity_set_subs_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Identity',
            'call_function': 'set_subs',
            'call_args': {
                'subs': [
                    ["EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk", {"None": None}],
                    ["EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk", {"Raw": "Test"}]
                ]
            }
        })

        self.assertEqual(str(payload),
                         "0x290104190208586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a8"
                         "0ac00225c40900586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c4090554657374")

    def test_encode_imonline_heartbeat_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'ImOnline',
            'call_function': 'heartbeat',
            'call_args': {
                'heartbeat': {
                    "block_number": 500000, "network_state": {"peer_id": "0x012345", "external_addresses": []},
                    "session_index": 1, "authority_index": 3
                },
                '_signature': '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
                              '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
            }
        })

        self.assertEqual(str(payload),
                         "0x5101040b0020a107000c0123450001000000030000000123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef")

    def test_encode_parachains_set_heads_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Parachains',
            'call_function': 'set_heads',
            'call_args': {
                'heads': [{
                    'candidate': {
                        "parachain_index": 1,
                        "collator": "0x0000000000000000000000000000000000000000000000000000000000000000",
                        "relay_parent": "0x1ec24d8af5e02482f603722c203659c3373304098d26c6b65be03a2b9e79cc0d",
                        "signature": "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
                        "head_data": "0x012345",
                        "balance_uploads": [],
                        "egress_queue_roots": [],
                        "fees": 0,
                        "pov_block_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
                        "block_data_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
                        "commitments": {
                            "fees": 0,
                            "upward_messages": [],
                            "horizontal_messages": [],
                            "head_data": "",
                            "hrmp_watermark": 1,
                            "new_validation_code": None,
                            "processed_downward_messages": 1
                        }
                    },
                    'validity_votes': [],
                    'validator_indices': []
                }]
            }
        })

        self.assertEqual(str(payload),
                         "0xe90204140004010000001ec24d8af5e02482f603722c203659c3373304098d26c6b65be03a2b9e79cc0d0c01234500000000000000000000000000000000000000000000000000000000000000001234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef00000000000000000000000000000000000000000000000000000000000000000000000001000000010000000000")

    def test_encode_registrar_deregister_para_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Registrar',
            'call_function': 'deregister_para',
            'call_args': {
                'id': 1
            }
        })

        self.assertEqual(str(payload), "0x1004170104")

    def test_encode_registrar_deregister_parathread_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Registrar',
            'call_function': 'deregister_parathread',
            'call_args': {

            }
        })

        self.assertEqual(str(payload), "0x0c041705")

    def test_encode_registrar_register_para_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Registrar',
            'call_function': 'register_para',
            'call_args': {
                'code': '0x00',
                'id': 1,
                'info': {"manager": "5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY", "deposit": 100000000, "locked": True},
                'initial_head_data': '0x01'
            }
        })

        self.assertEqual(str(payload), "0xe404170004d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d00e1f5050000000000000000000000000104000401")

    def test_encode_registrar_register_parathread_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Registrar',
            'call_function': 'register_parathread',
            'call_args': {
                'code': '0x00',
                'initial_head_data': '0x01'
            }
        })

        self.assertEqual(str(payload), "0x1c04170304000401")

    def test_encode_registrar_select_parathread_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Registrar',
            'call_function': 'select_parathread',
            'call_args': {
                '_collator': '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
                '_head_hash': '0x0000000000000000000000000000000000000000000000000000000000000000',
                '_id': 1
            }
        })

        self.assertEqual(str(payload),
                         "0x1101041704040123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0000000000000000000000000000000000000000000000000000000000000000")

    def test_encode_registrar_set_thread_count_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Registrar',
            'call_function': 'set_thread_count',
            'call_args': {
                'count': 1000
            }
        })

        self.assertEqual(str(payload), "0x1c041702e8030000")

    def test_encode_registrar_swap_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Registrar',
            'call_function': 'swap',
            'call_args': {
                'other': 1
            }
        })

        self.assertEqual(str(payload), "0x1004170604")

    def test_encode_session_set_keys_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Session',
            'call_function': 'set_keys',
            'call_args': {
                'keys': {
                    "grandpa": "EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk",
                    "babe": "EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk",
                    "im_online": "EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk",
                    "authority_discovery": "EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk",
                    "parachains": "EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk"
                },
                'proof': '0x01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef'
            }
        })

        self.assertEqual(str(payload),
                         "0xa503040800586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409110101234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef01234567890abcdef")

    def test_encode_slots_bid_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Slots',
            'call_function': 'bid',
            'call_args': {
                'amount': 1000000000000000,
                'auction_index': 2,
                'first_slot': 3,
                'last_slot': 4,
                'sub': 1
            }
        })

        self.assertEqual(str(payload), "0x3c04160104080c100f0080c6a47e8d03")

    def test_encode_slots_bid_renew_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Slots',
            'call_function': 'bid_renew',
            'call_args': {
                'amount': 1000000000000000,
                'auction_index': 1,
                'first_slot': 2,
                'last_slot': 3
            }
        })

        self.assertEqual(str(payload), "0x3804160204080c0f0080c6a47e8d03")

    def test_encode_slots_elaborate_deploy_data_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Slots',
            'call_function': 'elaborate_deploy_data',
            'call_args': {
                'code': '0x00',
                'para_id': 1
            }
        })

        self.assertEqual(str(payload), "0x18041605040400")

    def test_encode_slots_fix_deploy_data_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Slots',
            'call_function': 'fix_deploy_data',
            'call_args': {
                'code_hash': '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
                'initial_head_data': '0x00',
                'para_id': 2,
                'sub': 1
            }
        })

        self.assertEqual(str(payload),
                         "0x9c04160404080123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0400")

    def test_encode_slots_new_auction_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Slots',
            'call_function': 'new_auction',
            'call_args': {
                'duration': 100000,
                'lease_period_index': 2
            }
        })

        self.assertEqual(str(payload), "0x20041600821a060008")

    def test_encode_slots_set_offboarding_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Slots',
            'call_function': 'set_offboarding',
            'call_args': {
                'dest': '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409'
            }
        })

        self.assertEqual(str(payload), "0x90041603ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_slots_set_offboarding_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Slots',
            'call_function': 'set_offboarding',
            'call_args': {
                'dest': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk'
            }
        })

        self.assertEqual(str(payload), "0x90041603ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_staking_bond_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Staking',
            'call_function': 'bond',
            'call_args': {
                'controller': '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409',
                'payee': 'Staked',
                'value': 1000000000000
            }
        })

        self.assertEqual(str(payload),
                         "0xac040600ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409070010a5d4e800")

    def test_encode_staking_bond_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Staking',
            'call_function': 'bond',
            'call_args': {
                'controller': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk',
                'payee': 'Staked',
                'value': 1000000000000
            }
        })

        self.assertEqual(str(payload),
                         "0xac040600ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409070010a5d4e800")

    def test_encode_staking_bond_extra_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Staking',
            'call_function': 'bond_extra',
            'call_args': {
                'max_additional': 1000000000000
            }
        })

        self.assertEqual(str(payload), "0x24040601070010a5d4e8")

    def test_encode_staking_cancel_deferred_slash_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Staking',
            'call_function': 'cancel_deferred_slash',
            'call_args': {
                'era': 1,
                'slash_indices': [0, 1, 2]
            }
        })

        self.assertEqual(str(payload), "0x5004060f010000000c000000000100000002000000")

    def test_encode_staking_chill_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Staking',
            'call_function': 'chill',
            'call_args': {

            }
        })

        self.assertEqual(str(payload), "0x0c040606")

    def test_encode_staking_force_new_era_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Staking',
            'call_function': 'force_new_era',
            'call_args': {

            }
        })

        self.assertEqual(str(payload), "0x0c04060b")

    def test_encode_staking_force_new_era_always_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Staking',
            'call_function': 'force_new_era_always',
            'call_args': {

            }
        })

        self.assertEqual(str(payload), "0x0c04060e")

    def test_encode_staking_force_no_eras_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Staking',
            'call_function': 'force_no_eras',
            'call_args': {

            }
        })

        self.assertEqual(str(payload), "0x0c04060a")

    def test_encode_staking_force_unstake_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Staking',
            'call_function': 'force_unstake',
            'call_args': {
                'stash': '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409'
            }
        })

        self.assertEqual(str(payload), "0x8c04060d586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_staking_force_unstake_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Staking',
            'call_function': 'force_unstake',
            'call_args': {
                'stash': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk'
            }
        })

        self.assertEqual(str(payload), "0x8c04060d586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_staking_nominate_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Staking',
            'call_function': 'nominate',
            'call_args': {
                'targets': ['0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409']
            }
        })

        self.assertEqual(str(payload), "0x9404060504ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_staking_nominate_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Staking',
            'call_function': 'nominate',
            'call_args': {
                'targets': ['EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk']
            }
        })

        self.assertEqual(str(payload), "0x9404060504ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_staking_set_controller_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Staking',
            'call_function': 'set_controller',
            'call_args': {
                'controller': '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409'
            }
        })

        self.assertEqual(str(payload), "0x90040608ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_staking_set_controller_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Staking',
            'call_function': 'set_controller',
            'call_args': {
                'controller': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk'
            }
        })

        self.assertEqual(str(payload), "0x90040608ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_staking_set_invulnerables_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Staking',
            'call_function': 'set_invulnerables',
            'call_args': {
                'validators': ['0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409',
                               '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409']
            }
        })

        self.assertEqual(str(payload),
                         "0x110104060c08586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_staking_set_invulnerables_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Staking',
            'call_function': 'set_invulnerables',
            'call_args': {
                'validators': ['EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk',
                               'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk']
            }
        })

        self.assertEqual(str(payload),
                         "0x110104060c08586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_staking_set_payee_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Staking',
            'call_function': 'set_payee',
            'call_args': {
                'payee': 'Staked'
            }
        })

        self.assertEqual(str(payload), "0x1004060700")

    def test_encode_staking_set_validator_count_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Staking',
            'call_function': 'set_validator_count',
            'call_args': {
                'new': 150
            }
        })

        self.assertEqual(str(payload), "0x140406095902")

    def test_encode_staking_unbond_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Staking',
            'call_function': 'unbond',
            'call_args': {
                'value': 1000000000000
            }
        })

        self.assertEqual(str(payload), "0x24040602070010a5d4e8")

    def test_encode_staking_validate_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Staking',
            'call_function': 'validate',
            'call_args': {
                'prefs': {"commission": 100}
            }
        })

        self.assertEqual(str(payload), "0x140406049101")

    def test_encode_staking_withdraw_unbonded_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Staking',
            'call_function': 'withdraw_unbonded',
            'call_args': {

            }
        })

        self.assertEqual(str(payload), "0x0c040603")

    def test_encode_system_fill_block_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'System',
            'call_function': 'fill_block',
            'call_args': {

            }
        })

        self.assertEqual(str(payload), "0x0c040000")

    def test_encode_system_kill_prefix_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'System',
            'call_function': 'kill_prefix',
            'call_args': {
                'prefix': '0x012345'
            }
        })

        self.assertEqual(str(payload), "0x1c0400060c012345")

    def test_encode_system_kill_storage_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'System',
            'call_function': 'kill_storage',
            'call_args': {
                'keys': ['0x0123456789abcdef', '0x0123456789abcdef']
            }
        })

        self.assertEqual(str(payload), "0x5804000508200123456789abcdef200123456789abcdef")

    def test_encode_system_remark_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'System',
            'call_function': 'remark',
            'call_args': {
                '_remark': '0x012345'
            }
        })

        self.assertEqual(str(payload), "0x1c0400010c012345")

    def test_encode_system_set_code_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'System',
            'call_function': 'set_code',
            'call_args': {
                'new': '0x012345'
            }
        })

        self.assertEqual(str(payload), "0x1c0400030c012345")

    def test_encode_system_set_heap_pages_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'System',
            'call_function': 'set_heap_pages',
            'call_args': {
                'pages': 100
            }
        })

        self.assertEqual(str(payload), "0x2c0400026400000000000000")

    def test_encode_system_set_storage_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'System',
            'call_function': 'set_storage',
            'call_args': {
                'items': [['key', 'value']]
            }
        })

        self.assertEqual(str(payload), "0x38040004040c6b65791476616c7565")

    def test_encode_technicalcommittee_execute_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'TechnicalCommittee',
            'call_function': 'execute',
            'call_args': {
                'proposal': {
                    'call_module': 'System',
                    'call_function': 'remark',
                    'call_args': {
                        '_remark': '0x0123456789'
                    }
                }
            }
        })

        self.assertEqual(str(payload), "0x2c040f010001140123456789")

    def test_encode_technicalcommittee_propose_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'TechnicalCommittee',
            'call_function': 'propose',
            'call_args': {
                'proposal': {
                    'call_module': 'System',
                    'call_function': 'remark',
                    'call_args': {
                        '_remark': '0x0123456789'
                    }
                },
                'threshold': 7
            }
        })

        self.assertEqual(str(payload), "0x30040f021c0001140123456789")

    def test_encode_technicalcommittee_set_members_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'TechnicalCommittee',
            'call_function': 'set_members',
            'call_args': {
                'new_members': ['0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409',
                                '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409']
            }
        })

        self.assertEqual(str(payload),
                         "0x1101040f0008586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_technicalcommittee_set_members_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'TechnicalCommittee',
            'call_function': 'set_members',
            'call_args': {
                'new_members': ['EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk',
                                'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk']
            }
        })

        self.assertEqual(str(payload),
                         "0x1101040f0008586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_technicalcommittee_vote_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'TechnicalCommittee',
            'call_function': 'vote',
            'call_args': {
                'approve': True,
                'index': 1,
                'proposal': '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
            }
        })

        self.assertEqual(str(payload), "0x94040f030123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0401")

    def test_encode_technicalmembership_add_member_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'TechnicalMembership',
            'call_function': 'add_member',
            'call_args': {
                'who': '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409'
            }
        })

        self.assertEqual(str(payload), "0x8c041100586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_technicalmembership_add_member_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'TechnicalMembership',
            'call_function': 'add_member',
            'call_args': {
                'who': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk'
            }
        })

        self.assertEqual(str(payload), "0x8c041100586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_technicalmembership_change_key_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'TechnicalMembership',
            'call_function': 'change_key',
            'call_args': {
                'new': '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409'
            }
        })

        self.assertEqual(str(payload), "0x8c041104586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_technicalmembership_change_key_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'TechnicalMembership',
            'call_function': 'change_key',
            'call_args': {
                'new': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk'
            }
        })

        self.assertEqual(str(payload), "0x8c041104586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_technicalmembership_remove_member_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'TechnicalMembership',
            'call_function': 'remove_member',
            'call_args': {
                'who': '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409'
            }
        })

        self.assertEqual(str(payload), "0x8c041101586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_technicalmembership_remove_member_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'TechnicalMembership',
            'call_function': 'remove_member',
            'call_args': {
                'who': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk'
            }
        })

        self.assertEqual(str(payload), "0x8c041101586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_technicalmembership_reset_members_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'TechnicalMembership',
            'call_function': 'reset_members',
            'call_args': {
                'members': ['0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409',
                            '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409']
            }
        })

        self.assertEqual(str(payload),
                         "0x110104110308586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_technicalmembership_reset_members_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'TechnicalMembership',
            'call_function': 'reset_members',
            'call_args': {
                'members': ['EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk',
                            'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk']
            }
        })

        self.assertEqual(str(payload),
                         "0x110104110308586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_technicalmembership_swap_member_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'TechnicalMembership',
            'call_function': 'swap_member',
            'call_args': {
                'add': '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409',
                'remove': '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409'
            }
        })

        self.assertEqual(str(payload),
                         "0x0d01041102586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_technicalmembership_swap_member_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'TechnicalMembership',
            'call_function': 'swap_member',
            'call_args': {
                'add': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk',
                'remove': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk'
            }
        })

        self.assertEqual(str(payload),
                         "0x0d01041102586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_timestamp_set_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Timestamp',
            'call_function': 'set',
            'call_args': {
                'now': 1
            }
        })

        self.assertEqual(str(payload), "0x1004020004")

    def test_encode_treasury_approve_proposal_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Treasury',
            'call_function': 'approve_proposal',
            'call_args': {
                'proposal_id': 1
            }
        })

        self.assertEqual(str(payload), "0x1004120204")

    def test_encode_treasury_propose_spend_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Treasury',
            'call_function': 'propose_spend',
            'call_args': {
                'beneficiary': '0x586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409',
                'value': 1000000000000
            }
        })

        self.assertEqual(str(payload),
                         "0xa8041200070010a5d4e8ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_treasury_propose_spend_ss58_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Treasury',
            'call_function': 'propose_spend',
            'call_args': {
                'beneficiary': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk',
                'value': 1000000000000
            }
        })

        self.assertEqual(str(payload),
                         "0xa8041200070010a5d4e8ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409")

    def test_encode_treasury_reject_proposal_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Treasury',
            'call_function': 'reject_proposal',
            'call_args': {
                'proposal_id': 1
            }
        })

        self.assertEqual(str(payload), "0x1004120104")

    def test_encode_utility_approve_as_multi_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Utility',
            'call_function': 'approve_as_multi',
            'call_args': {
                'call_hash': '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
                'maybe_timepoint': {
                    'height': 444,
                    'index': 10
                },
                'other_signatories': ['EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk'],
                'threshold': 4
            }
        })

        self.assertEqual(str(payload), "0x3d01041803040004586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c40901bc0100000a0000000123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef")

    def test_encode_utility_as_multi_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Utility',
            'call_function': 'as_multi',
            'call_args': {
                'call': {
                    'call_module': 'System',
                    'call_function': 'remark',
                    'call_args': {
                        '_remark': '0x0123456789'
                    }
                },
                'maybe_timepoint': None,
                'other_signatories': [],
                'threshold': 5
            }
        })

        self.assertEqual(str(payload),
                         "0x3c041802050000000001140123456789")

    def test_encode_utility_as_sub_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Utility',
            'call_function': 'as_sub',
            'call_args': {
                'call': {
                    'call_module': 'System',
                    'call_function': 'remark',
                    'call_args': {
                        '_remark': '0x0123456789'
                    }
                },
                'index': 2
            }
        })

        self.assertEqual(str(payload), "0x3404180102000001140123456789")

    def test_encode_utility_batch_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Utility',
            'call_function': 'batch',
            'call_args': {
                'calls': [{
                    'call_module': 'Balances',
                    'call_function': 'transfer',
                    'call_args': {
                        'dest': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk',
                        'value': 1000000000000
                    }
                }]
            }
        })

        self.assertEqual(str(payload), "0xb4041800040400ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409070010a5d4e8")

    def test_encode_utility_batch_payload_scaletype(self):
        call = RuntimeConfiguration().create_scale_object("Call", metadata=self.metadata_decoder)

        call.encode({
            'call_module': 'Balances',
            'call_function': 'transfer',
            'call_args': {
                'dest': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk',
                'value': 1000000000000
            }
        })

        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Utility',
            'call_function': 'batch',
            'call_args': {
                'calls': [call]
            }
        })

        self.assertEqual(str(payload), "0xb4041800040400ff586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409070010a5d4e8")

    def test_encode_utility_batch_single_payload_scaletype_v14(self):
        call = self.runtime_config_v14.create_scale_object("Call", metadata=self.metadata_v14_obj)

        call.encode({
            'call_module': 'Balances',
            'call_function': 'transfer',
            'call_args': {
                'dest': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk',
                'value': 1000000000000
            }
        })

        extrinsic = self.runtime_config_v14.create_scale_object("Extrinsic", metadata=self.metadata_v14_obj)

        payload = extrinsic.encode({
            'call_module': 'Utility',
            'call_function': 'batch',
            'call_args': {
                'calls': [call]
            }
        })

        self.assertEqual("0xb404010004060000586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409070010a5d4e8", str(payload))

    def test_encode_utility_batch_multiple_payload_scaletype_v14(self):
        call = self.runtime_config_v14.create_scale_object("Call", metadata=self.metadata_v14_obj)

        call.encode({
            'call_module': 'Balances',
            'call_function': 'transfer',
            'call_args': {
                'dest': 'EaG2CRhJWPb7qmdcJvy3LiWdh26Jreu9Dx6R1rXxPmYXoDk',
                'value': 1000000000000
            }
        })

        extrinsic = self.runtime_config_v14.create_scale_object("Extrinsic", metadata=self.metadata_v14_obj)

        payload = extrinsic.encode({
            'call_module': 'Utility',
            'call_function': 'batch',
            'call_args': {
                'calls': [call, call]
            }
        })

        self.assertEqual("0x590104010008060000586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409070010a5d4e8060000586cb27c291c813ce74e86a60dad270609abf2fc8bee107e44a80ac00225c409070010a5d4e8", str(payload))

    def test_encode_utility_cancel_as_multi_payload(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        payload = extrinsic.encode({
            'call_module': 'Utility',
            'call_function': 'cancel_as_multi',
            'call_args': {
                'call_hash': '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
                'other_signatories': [],
                'threshold': 5,
                'timepoint': {
                    'height': 10000,
                    'index': 1
                }
            }
        })

        self.assertEqual(str(payload), "0xb804180405000010270000010000000123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef")

    def test_signed_extrinsic(self):
        extrinsic = Extrinsic(metadata=self.metadata_decoder)

        extrinsic_value = {
            'account_id': '5E9oDs9PjpsBbxXxRE9uMaZZhnBAV38n2ouLB28oecBDdeQo',
            'signature_version': 1,
            'signature': '0x728b4057661816aa24918219ff90d10a34f1db4e81494d23c83ef54991980f77cf901acd970cb36d3c9c9e166d27a83a3aee648d4085e2bdb9e7622c0538e381',
            'call': {
                'call_function': 'transfer',
                'call_module': 'Balances',
                'call_args': {
                    'dest': '0xd43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d',
                    'value': 1000000000000
                }
            },
            'nonce': 0,
            'era': '00',
            'tip': 0
        }

        extrinsic_hex = extrinsic.encode(extrinsic_value)

        obj = RuntimeConfiguration().create_scale_object(
            "Extrinsic",
            data=extrinsic_hex,
            metadata=self.metadata_decoder
        )

        decoded_extrinsic = obj.decode()

        self.assertEqual(extrinsic_value['signature'], decoded_extrinsic['signature'])
        self.assertEqual(extrinsic_value['call']['call_args']['dest'], decoded_extrinsic['call']['call_args'][0]['value'])

    def test_decode_mortal_extrinsic(self):
        RuntimeConfiguration().update_type_registry(load_type_registry_preset("substrate-node-template"))
        RuntimeConfiguration().set_active_spec_version_id(1)

        metadata_decoder = RuntimeConfiguration().create_scale_object(
            'MetadataVersioned', ScaleBytes(metadata_substrate_node_template)
        )
        metadata_decoder.decode()

        extrinsic_scale = '0x4102841c0d1aa34c4be7eaddc924b30bab35e45ec22307f2f7304d6e5f9c8f3753de560186be385b2f7b25525518259b00e6b8a61e7e821544f102dca9b6d89c60fc327922229c975c2fa931992b17ab9d5b26f9848eeeff44e0333f6672a98aa8b113836935040005031c0d1aa34c4be7eaddc924b30bab35e45ec22307f2f7304d6e5f9c8f3753de560f0080c6a47e8d03'

        extrinsic = Extrinsic(metadata=metadata_decoder, data=ScaleBytes(extrinsic_scale))
        extrinsic.decode()

        self.assertEqual(extrinsic['call']['call_function'].name, 'transfer_keep_alive')

        era_obj = RuntimeConfiguration().create_scale_object('Era')
        era_obj.encode({'period': 666, 'current': 4950})

        self.assertEqual(extrinsic['era'].period, era_obj.period)
        self.assertEqual(extrinsic['era'].phase, era_obj.phase)
        self.assertEqual(extrinsic['era'].get_used_bytes(), era_obj.data.data)

        # Check lifetime of transaction
        self.assertEqual(extrinsic['era'].birth(4955), 4950)
        self.assertEqual(extrinsic['era'].death(4955), 5974)

    def test_encode_mortal_extrinsic(self):
        RuntimeConfiguration().update_type_registry(load_type_registry_preset("substrate-node-template"))
        RuntimeConfiguration().set_active_spec_version_id(1)

        metadata_decoder = RuntimeConfiguration().create_scale_object(
            'MetadataVersioned', ScaleBytes(metadata_substrate_node_template)
        )
        metadata_decoder.decode()

        extrinsic = Extrinsic(metadata=metadata_decoder)

        extrinsic_value = {
            'account_id': '5ChV6DCRkvaTfwNHsiE2y3oQyPwTJqDPmhEUoEx1t1dupThE',
            'signature_version': 1,
            'signature': '0x86be385b2f7b25525518259b00e6b8a61e7e821544f102dca9b6d89c60fc327922229c975c2fa931992b17ab9d5b26f9848eeeff44e0333f6672a98aa8b11383',
            'call': {
                'call_function': 'transfer_keep_alive',
                'call_module': 'Balances',
                'call_args': {
                    'dest': '5ChV6DCRkvaTfwNHsiE2y3oQyPwTJqDPmhEUoEx1t1dupThE',
                    'value': 1000000000000000
                }
            },
            'nonce': 1,
            'era': {'period': 666, 'current': 4950},
            'tip': 0
        }

        extrinsic_hex = extrinsic.encode(extrinsic_value)
        extrinsic_scale = '0x4102841c0d1aa34c4be7eaddc924b30bab35e45ec22307f2f7304d6e5f9c8f3753de560186be385b2f7b25525518259b00e6b8a61e7e821544f102dca9b6d89c60fc327922229c975c2fa931992b17ab9d5b26f9848eeeff44e0333f6672a98aa8b113836935040005031c0d1aa34c4be7eaddc924b30bab35e45ec22307f2f7304d6e5f9c8f3753de560f0080c6a47e8d03'

        self.assertEqual(str(extrinsic_hex), extrinsic_scale)
