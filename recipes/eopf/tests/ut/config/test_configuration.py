#
# Copyright (C) 2026 CS Group
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
import os
from unittest import mock

import pytest

from eopf.common.constants import EOPF_CPM_DEFAULT_CONFIG_FILE
from eopf.common.file_utils import AnyPath
from eopf.config.config import ConfigFileType, EOConfiguration
from eopf.exceptions import MissingConfigurationParameterError


@pytest.fixture
def clean_conf():
    EOConfiguration().clear_loaded_configurations()


@pytest.fixture
def INI_CONF_FILE(FOLDER_WITH_CONFIGS):
    return os.path.join(FOLDER_WITH_CONFIGS, "conf.ini")


@pytest.fixture
def TOML_CONF_FILE(FOLDER_WITH_CONFIGS):
    return os.path.join(FOLDER_WITH_CONFIGS, "conf.toml")


@pytest.fixture
def CONFIGURATION_FOLDER(OUTPUT_DIR):
    os.makedirs(os.path.join(OUTPUT_DIR, "CONFIGURATION_FOLDER"), exist_ok=True)
    any = AnyPath(os.path.join(OUTPUT_DIR, "CONFIGURATION_FOLDER", "eopf.toml"))
    any.touch()
    return os.path.join(OUTPUT_DIR, "CONFIGURATION_FOLDER")


@pytest.mark.unit
@pytest.mark.no_autouse_fixture
def test_load(clean_conf, FOLDER_WITH_CONFIGS, INI_CONF_FILE):
    with (
        mock.patch.dict(
            os.environ,
            {
                "EOPF_CONFIGURATION_FOLDER": FOLDER_WITH_CONFIGS,
                "EOPF_INVALID_KEY": "environ_false_value",
                "OTHERS": "not_parsed",
            },
        ),
    ):
        config = EOConfiguration()
        print(config.param_list_available)
        config.load_file(INI_CONF_FILE)
        print(config.param_list_available)
        assert config.eopf__configuration_folder == "ini_parsed_value"
        EOConfiguration().clear_loaded_configurations()


@pytest.mark.unit
@pytest.mark.no_autouse_fixture
def test_default_configuration_is_not_loaded_implicitly(clean_conf):
    config = EOConfiguration()

    assert str(EOPF_CPM_DEFAULT_CONFIG_FILE) not in config._param_file_list
    assert not config.has_value("general__description")


@pytest.mark.unit
@pytest.mark.no_autouse_fixture
def test_load_default_file_is_explicit(clean_conf):
    config = EOConfiguration()

    config.load_default_file()

    assert str(EOPF_CPM_DEFAULT_CONFIG_FILE) in config._param_file_list
    assert config.general__description == "An example configuration file with complex structures."


@pytest.mark.unit
@pytest.mark.no_autouse_fixture
def test_load_ini(clean_conf, FOLDER_WITH_CONFIGS, INI_CONF_FILE):
    config = EOConfiguration()
    config.load_file(INI_CONF_FILE)
    assert config.eopf__configuration_folder == "ini_parsed_value"
    EOConfiguration().clear_loaded_configurations()


@pytest.mark.unit
@pytest.mark.no_autouse_fixture
def test_load_toml(clean_conf, FOLDER_WITH_CONFIGS, TOML_CONF_FILE):
    config = EOConfiguration()
    config.load_file(TOML_CONF_FILE, file_config_type=ConfigFileType.TOML)
    assert config.tool__eopf__configuration_folder == "toml_parsed_value"
    EOConfiguration().clear_loaded_configurations()


@pytest.mark.unit
@pytest.mark.no_autouse_fixture
def test_load_environ(clean_conf, FOLDER_WITH_CONFIGS):
    with mock.patch.dict(
        os.environ,
        {
            "EOPF_MACHIN_FOLDER": "environ_parsed_value",
            "EOPF_INVALID_KEY": "environ_false_value",
            "OTHERS": "not_parsed",
        },
    ):
        config = EOConfiguration()
        config._load_environ()
        assert config.machin_folder == "environ_parsed_value"
        with pytest.raises(MissingConfigurationParameterError):
            config.get("machin", throws=True)
        assert config.get("machin") is None
        EOConfiguration().clear_loaded_configurations()


@pytest.mark.unit
@pytest.mark.no_autouse_fixture
def test_load_environ_scans_once_until_refresh(clean_conf):
    with mock.patch.dict(os.environ, {"EOPF_SCAN_ONCE": "first"}):
        config = EOConfiguration()
        config._load_environ()
        assert config.scan_once == "first"

        os.environ["EOPF_SCAN_ONCE"] = "second"
        config._load_environ()
        assert config.scan_once == "first"

        config.refresh_environ()
        assert config.scan_once == "second"
        EOConfiguration().clear_loaded_configurations()


@pytest.mark.unit
@pytest.mark.no_autouse_fixture
def test_requested_params_description(clean_conf, CONFIGURATION_FOLDER):
    with mock.patch.dict(
        os.environ,
        {
            "EOPF_CONFIGURATION_FOLDER": CONFIGURATION_FOLDER,
        },
    ):
        config = EOConfiguration()
        description = config.requested_params_description()
        base_num = len(description["optional"])
        config.register_requested_parameter("foo", "bar", description="foobar")
        config.register_requested_parameter(
            "foo1",
            param_is_optional=False,
        )  # in case the user wants to handle the missing case
        config["foo1"] = "truc"
        config.register_requested_parameter("foo1")
        description = config.requested_params_description()
        print(description["optional"])
        assert len(description["optional"]) == base_num + 1
        assert len(description["mandatory"]) == 1
        assert description["optional"]["foo"] == {
            "name": "foo",
            "optional": True,
            "default": "bar",
            "description": "foobar",
        }
        EOConfiguration().clear_loaded_configurations()
        config["foo2"] = "truc"
        config["foo1"] = "truc"


@pytest.mark.unit
@pytest.mark.no_autouse_fixture
def test_register_parameter_with_default(
    clean_conf,
):
    config = EOConfiguration()
    config.register_requested_parameter("foo", "bar")
    config.register_requested_parameter("foo2", param_is_optional=False)
    config.register_requested_parameter("foo3", param_is_optional=True)
    config["foo2"] = "truc"
    assert config.foo == "bar"
    assert "foo2" in config.mandatory_list()
    assert "foo3" in config.optional_list()
    EOConfiguration().clear_loaded_configurations()
    config["foo2"] = "truc"
    config["foo1"] = "truc"


@pytest.mark.unit
@pytest.mark.no_autouse_fixture
def test_register_parameter_no_default(
    clean_conf,
):
    from eopf.exceptions.errors import MissingConfigurationParameterError

    config = EOConfiguration()
    config.register_requested_parameter("foonodefaults", param_is_optional=False)
    with pytest.raises(MissingConfigurationParameterError):
        print(config.foonodefaults)
    missing = config.get_missing_mandatory_parameters()
    assert missing
    with pytest.raises(MissingConfigurationParameterError, match=r"Missing parameters: .* in configuration files"):
        config.validate_mandatory_parameters()
    config["foonodefaults"] = "machin"
    config["foo2"] = "truc"
    config["foo1"] = "truc"
    config.validate_mandatory_parameters()
    EOConfiguration().clear_loaded_configurations()
    config["foo2"] = "truc"
    config["foonodefaults"] = "machin"
    config["foo1"] = "truc"
