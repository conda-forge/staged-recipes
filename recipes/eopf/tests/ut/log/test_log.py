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
import logging
from logging import CRITICAL, DEBUG, ERROR, INFO, WARNING, Logger
from pathlib import Path

import pytest

from eopf.exceptions import LoggingConfigurationDirDoesNotExist, LoggingConfigurationFileTypeNotSupported
from eopf.exceptions.warnings import LoggingLevelIsNoneStandard, NoLoggingConfigurationFile
from eopf.logging import configure_logging_from_directory, configure_logging_from_file, reset_logging, setup_basic_logging
from eopf.logging.log import obfuscate_passwords


@pytest.mark.unit
def test_standard_logging_returns_logger():
    """Test that the standard logging module returns a Logger object."""
    test_log = logging.getLogger(__name__)
    assert isinstance(test_log, Logger)


@pytest.mark.unit
def test_non_existent_cfg_dir():
    """Test that configuring logging from a non-existent dir raises LoggingConfigurationDirDoesNotExist."""
    with pytest.raises(LoggingConfigurationDirDoesNotExist):
        configure_logging_from_directory("/tmp/does_not_exist")


@pytest.mark.unit
def test_configure_logging_from_file_with_incorrect_file_path():
    """Test that configuring logging from a non-existent file raises FileNotFoundError."""
    with pytest.raises(FileNotFoundError):
        configure_logging_from_file("")


@pytest.mark.unit
def test_configure_logging_from_file_with_incorrect_file_extension(tmp_path: Path):
    """Test that configuring logging from an unsupported file extension raises."""
    test_file_path = tmp_path / "log_conf.jso"
    test_file_path.write_text("{}", encoding="utf-8")
    with pytest.raises(LoggingConfigurationFileTypeNotSupported):
        configure_logging_from_file(test_file_path)


@pytest.mark.unit
def test_configure_logging_from_directory_with_no_log_configurations():
    """Test that mandatory configuration from an empty dir raises NoLoggingConfigurationFile."""
    test_dir_path = Path(__file__).parent
    with pytest.raises(NoLoggingConfigurationFile):
        configure_logging_from_directory(test_dir_path, mandatory=True)


@pytest.mark.parametrize(
    "expected_log_level",
    [
        DEBUG,
        INFO,
        WARNING,
        ERROR,
        CRITICAL,
    ],
)
@pytest.mark.unit
def test_override_log_cfg_level_with_standard_level_value(expected_log_level: int):
    """Test setup_basic_logging accepts standard level values."""
    reset_logging()
    setup_basic_logging(level=expected_log_level)
    assert logging.getLogger().level == expected_log_level


@pytest.mark.parametrize(
    "log_level",
    [
        "TARTENPION",
        "BECASSE",
    ],
)
@pytest.mark.unit
def test_override_log_cfg_level_with_non_standard_level_value(log_level: str):
    """Test setup_basic_logging rejects non-standard level values."""
    with pytest.raises(LoggingLevelIsNoneStandard):
        setup_basic_logging(level=log_level)


@pytest.mark.unit
def test_get_logger_does_not_override_level_with_none():
    """Test the override log level functionaly of the get_logger"""
    logger = logging.getLogger("eopf.test.log.none")
    assert logger.level == logging.NOTSET


@pytest.mark.unit
def test_setup_basic_logging_accepts_standard_string_level():
    reset_logging()
    setup_basic_logging(level="INFO")
    assert logging.getLogger().level == INFO


@pytest.mark.unit
def test_unit_logging_configures_eopf_dask_and_distributed_loggers(FOLDER_WITH_LOGGING_CONFIGS):
    """Test the unit logging directory configures project and dask loggers with timestamps."""
    reset_logging()
    configure_logging_from_directory(FOLDER_WITH_LOGGING_CONFIGS, mandatory=True)

    for logger_name in ("eopf", "dask", "distributed"):
        logger = logging.getLogger(logger_name)
        assert logger.level == DEBUG
        assert not logger.disabled
        assert logger.handlers
        assert any("%(asctime)s" in handler.formatter._fmt for handler in logger.handlers)

    assert logging.getLogger("dask").propagate
    assert logging.getLogger("distributed").propagate
    assert not logging.getLogger("distributed.worker").disabled


@pytest.mark.unit
@pytest.mark.parametrize(
    "instr,outstr",
    [
        (
            "'address': 'http://localhost:8702', 'reuse_cluster': '${CLUSTER_NAME}','auth': {'type': 'basic', "
            "'username': 'jgaucher','password': 'F_41_bugNEkAQ7A...'",
            "'address': 'http://localhost:8702', 'reuse_cluster': '${CLUSTER_NAME}',"
            "'auth': {'type': 'basic', 'username': '****',"
            "'password': '****'",
        ),
    ],
)
def test_password_filter(instr: str, outstr: str):
    assert outstr == obfuscate_passwords(instr)
