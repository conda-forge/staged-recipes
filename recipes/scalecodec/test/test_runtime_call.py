import unittest

from scalecodec.base import RuntimeConfigurationObject
from scalecodec.type_registry import load_type_registry_preset


class RuntimeCallTestCase(unittest.TestCase):

    runtime_config: RuntimeConfigurationObject

    @classmethod
    def setUpClass(cls):
        cls.runtime_config = RuntimeConfigurationObject()
        cls.runtime_config.clear_type_registry()
        cls.runtime_config.update_type_registry(load_type_registry_preset("core"))

    def test_encode_runtime_calls(self):
        for api, methods in self.runtime_config.type_registry["runtime_api"].items():

            runtime_api_types = self.runtime_config.type_registry["runtime_api"][api].get("types", {})
            # Add runtime API types to registry
            self.runtime_config.update_type_registry_types(runtime_api_types)

            for method, runtime_call in methods["methods"].items():
                runtime_call['api'] = api
                runtime_call['method'] = method

                runtime_call_obj = self.runtime_config.create_scale_object("RuntimeCallDefinition")
                runtime_call_obj.encode(runtime_call)

                self.assertEqual(runtime_call_obj.value['method'], method)
                self.assertIn('params', runtime_call_obj.value)

