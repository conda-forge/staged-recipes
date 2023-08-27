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
#
#  test_runtime_configuration.py
#

import unittest

from scalecodec import Struct
from scalecodec.base import RuntimeConfiguration, RuntimeConfigurationObject
from scalecodec.type_registry import load_type_registry_preset


class TestScaleDecoderClasses(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.runtime_config = RuntimeConfigurationObject()
        cls.runtime_config.clear_type_registry()
        cls.runtime_config.update_type_registry(load_type_registry_preset("core"))
        cls.runtime_config.update_type_registry(load_type_registry_preset("legacy"))

    def test_valid_decoding_classes(self):
        for type_string in self.runtime_config.type_registry['types'].keys():

            decoding_cls = self.runtime_config.get_decoder_class(type_string)

            self.assertIsNotNone(decoding_cls, msg='"{}" didn\'t return decoding class'.format(type_string))


class TestMultipleRuntimeConfigurations(unittest.TestCase):

    def test_use_config_singleton(self):
        RuntimeConfiguration(config_id='test').update_type_registry({
            'types': {
                'CustomTestType': 'u8'
            }
        })
        self.assertIsNone(RuntimeConfiguration().get_decoder_class('CustomTestType'))
        self.assertIsNotNone(RuntimeConfiguration(config_id='test').get_decoder_class('CustomTestType'))

    def test_multiple_instances(self):
        runtime_config1 = RuntimeConfigurationObject()
        runtime_config1.update_type_registry({
            'types': {
                'MyNewType': 'Vec<u8>'
            }
        })

        runtime_config2 = RuntimeConfigurationObject()

        self.assertIsNone(RuntimeConfigurationObject().get_decoder_class('MyNewType'))
        self.assertIsNotNone(runtime_config1.get_decoder_class('MyNewType'))
        self.assertIsNone(runtime_config2.get_decoder_class('MyNewType'))


class TestRuntimeIdCache(unittest.TestCase):

    def test_runtime_id_cache_lookup(self):
        runtime_config = RuntimeConfigurationObject()
        runtime_config.update_type_registry(load_type_registry_preset("legacy"))
        runtime_config.update_type_registry(load_type_registry_preset("kusama"))

        self.assertEqual(1023, runtime_config.get_runtime_id_from_upgrades(54248))
        self.assertEqual(1020, runtime_config.get_runtime_id_from_upgrades(0))

    def test_set_head(self):
        runtime_config = RuntimeConfigurationObject()
        runtime_config.update_type_registry(load_type_registry_preset("legacy"))
        runtime_config.update_type_registry(load_type_registry_preset("kusama"))

        self.assertIsNone(runtime_config.get_runtime_id_from_upgrades(99999999998))

        # Set head to block
        runtime_config.set_runtime_upgrades_head(99999999999)

        # Check updated cache
        self.assertGreater(runtime_config.get_runtime_id_from_upgrades(99999999998), 0)


if __name__ == '__main__':
    unittest.main()
