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
import json
import os
from pathlib import Path
from typing import Any

from eopf.config.secrets_manager import SecretsManager
from eopf.config.secret_providers.file_secret_store import FileSecretStore
import fsspec
import pytest

from eopf.common.constants import EOPF_CPM_PATH
from eopf.common.file_utils import AnyPath
from eopf.common.yaml_codecs import register_yaml_codecs

# ----------------------------------#
# --- pytest command line options --#
# ----------------------------------#
PARENT_DATA_PATH = os.path.abspath(
    os.path.join(os.path.abspath(os.path.dirname(__file__)), ".."),
)
EOPF_CPM_TESTS_PATH = os.path.join(os.path.dirname(EOPF_CPM_PATH), "tests")
TEST_ONLY_ONE_PRODUCT = os.environ.get("TEST_ONLY_ONE_PRODUCT") in [True, "True", "true", 1, "1"]
TEST_DATA_PATH = os.path.join(PARENT_DATA_PATH, os.path.abspath(os.environ.get("TEST_DATA_FOLDER", "data")))
# MAPPING_PATH = os.path.join(PARENT_DATA_PATH, "eopf", "store", "mapping")
MAPPING_PATH = os.path.join(EOPF_CPM_PATH, "store", "mapping")

register_yaml_codecs()


# yaml.SafeLoader.add_constructor("!ZarrCompressor", compressor_cstr)
# yaml.SafeDumper.add_representer(numcodecs.blosc.Blosc, compressor_repr)


def pytest_addoption(parser):
    parser.addoption(
        "--s3",
        action="store_true",
        default=False,
        help="run real s3 tests",
    )
    parser.addoption(
        "--no-dask",
        action="store_true",
        default=False,
        help="run tests that do not require dask or distributed",
    )
    parser.addoption(
        "--integration",
        action="store_true",
        default=False,
        help="run integration tests",
    )


def pytest_configure(config):
    config.addinivalue_line("markers", "real_s3: mark test as requiring real s3")
    config.addinivalue_line("markers", "dask_only: mark test as requiring dask or distributed")
    config.addinivalue_line("markers", "no_autouse_fixture: no autouse on this test")
    config.addinivalue_line("markers", "gateway: mark test as requiring dask gateway")


def pytest_collection_modifyitems(config, items):
    s3_opt = config.getoption("--s3")
    no_dask_opt = config.getoption("--no-dask")
    skip_s3 = pytest.mark.skip(reason="need --s3 option to run")
    selected_items = []
    deselected_items = []
    for item in items:
        if "real_s3" in item.keywords and not s3_opt:
            item.add_marker(skip_s3)
        if "dask_only" in item.keywords and no_dask_opt:
            deselected_items.append(item)
        else:
            selected_items.append(item)
    if deselected_items:
        config.hook.pytest_deselected(items=deselected_items)
        items[:] = selected_items


def pytest_ignore_collect(collection_path: Path, config):
    path = collection_path

    if "it" in path.parts and not config.getoption("--integration"):
        return True

    return False


# ----------------------------------#
# ---------- DATA FOLDER -----------#
# ----------------------------------#


def _get_env_or_fail(name: str) -> str:
    value = os.environ.get(name)
    if not value:
        raise RuntimeError(f"Missing required environment variable: {name}")
    return value


@pytest.fixture
def s3_test_data() -> tuple[str | None, str]:
    return fsspec.core.split_protocol(os.environ.get("S3_TEST_DATA_FOLDER", ""))


def _add_unit_test_output_prefix(path: str) -> str:
    normalized = path.strip("/")
    if normalized.split("/")[-1:] == ["unit_test_output"]:
        return normalized
    return f"{normalized}/unit_test_output"


@pytest.fixture
def s3_output_test_data(s3_output_config_real) -> tuple[str | None, str]:
    protocol, path = fsspec.core.split_protocol(os.environ.get("S3_OUTPUT_TEST_DATA_FOLDER", ""))
    if protocol is None:
        return protocol, path

    prefixed_path = _add_unit_test_output_prefix(path)
    AnyPath(f"{protocol}://{prefixed_path}", **s3_output_config_real).mkdir(exist_ok=True)
    return protocol, prefixed_path


@pytest.fixture
def s3_config_fake() -> dict[str, Any]:
    return {
        "check": False,
        "create": False,
        "key": "aaaa",
        "secret": "bbbbb",
        "client_kwargs": {
            "endpoint_url": "https://localhost",
            "region_name": "local",
        },
    }


@pytest.fixture
def s3_config_real() -> dict[str, Any]:
    return {
        "key": _get_env_or_fail("S3_KEY"),
        "secret": _get_env_or_fail("S3_SECRET"),
        "client_kwargs": {
            "endpoint_url": _get_env_or_fail("S3_URL"),
            "region_name": _get_env_or_fail("S3_REGION"),
        },
    }

@pytest.fixture(autouse=True)
def reset_credential_store_s3():
    try:
        SecretsManager.clear()
        yield
    finally:
        SecretsManager.clear()

@pytest.fixture
def obstore_s3_config_real() -> dict[str, Any]:
    return {
        "access_key_id": _get_env_or_fail("S3_KEY"),
        "secret_access_key": _get_env_or_fail("S3_SECRET"),
        "endpoint_url": _get_env_or_fail("S3_URL"),
        "region": _get_env_or_fail("S3_REGION"),
    }


@pytest.fixture
def s3_output_config_real() -> dict[str, Any]:
    return {
        "key": _get_env_or_fail("S3_OUTPUT_KEY"),
        "secret": _get_env_or_fail("S3_OUTPUT_SECRET"),
        "client_kwargs": {
            "endpoint_url": _get_env_or_fail("S3_OUTPUT_URL"),
            "region_name": _get_env_or_fail("S3_OUTPUT_REGION"),
        },
    }


@pytest.fixture
def obstore_s3_output_config_real() -> dict[str, Any]:
    return {
        "access_key_id": _get_env_or_fail("S3_OUTPUT_KEY"),
        "secret_access_key": _get_env_or_fail("S3_OUTPUT_SECRET"),
        "endpoint_url": _get_env_or_fail("S3_OUTPUT_URL"),
        "region": _get_env_or_fail("S3_OUTPUT_REGION"),
    }


@pytest.fixture(scope="session")
def INPUT_DIR():
    """Path to the folder from where the input data should be read"""
    folder = TEST_DATA_PATH
    if os.path.isdir(folder):
        return folder
    raise FileNotFoundError(
        f"{folder=} does not exist or is not accessible, "
        "please refer to the online documentation to setup test data: "
        "https://cpm.pages.csc-eopf.csgroup.space/eopf-cpm/main/contributing.html#testing",
    )


@pytest.fixture
def OUTPUT_DIR(tmp_path):
    """Path to the folder where the output data should be written"""
    if output_folder := os.environ.get("TEST_OUTPUT_FOLDER"):
        if not os.path.exists(output_folder):
            os.makedirs(output_folder)
        yield output_folder
        # shutil.rmtree(output_folder)
    else:
        yield str(tmp_path.absolute())


@pytest.fixture(scope="session")
def MAPPING_FOLDER():
    """Path to the folder that contains all the mappings"""
    return MAPPING_PATH


# ----------------------------------#
# ------------ MAPPING -------------#
# ----------------------------------#


@pytest.fixture(scope="session")
def S01SIWGRD_MAPPING(MAPPING_FOLDER: str):
    """Path to a S1 LEVEL 1 mapping"""
    return os.path.join(MAPPING_FOLDER, "S01SIWGRD_pv1.0.0_mv1.0.0.json")


@pytest.fixture(scope="session")
def S01SIWSLC_MAPPING(MAPPING_FOLDER: str):
    """Path to a S1 LEVEL 1 mapping"""
    return os.path.join(MAPPING_FOLDER, "S01SIWSLC_pv1.0.0_mv1.0.0.json")


@pytest.fixture(scope="session")
def S01SIWRAW_MAPPING(MAPPING_FOLDER: str):
    """Path to a S1 RAW IW Level 0 mapping"""
    return os.path.join(MAPPING_FOLDER, "S01SIWRAW_pv1.0.0_mv1.0.0.json")


@pytest.fixture(scope="session")
def S01SSMRAW_MAPPING(MAPPING_FOLDER: str):
    """Path to a S1 RAW SM Level 0 mapping"""
    return os.path.join(MAPPING_FOLDER, "S01SSMRAW_pv1.0.0_mv1.0.0.json")


@pytest.fixture(scope="session")
def S01SEWRAW_MAPPING(MAPPING_FOLDER: str):
    """Path to a S1 RAW EW Level 0 mapping"""
    return os.path.join(MAPPING_FOLDER, "S01SEWRAW_pv1.0.0_mv1.0.0.json")


@pytest.fixture(scope="session")
def S01SWVRAW_MAPPING(MAPPING_FOLDER: str):
    """Path to a S1 RAW WV Level 0 mapping"""
    return os.path.join(MAPPING_FOLDER, "S01SWVRAW_pv1.0.0_mv1.0.0.json")


@pytest.fixture(scope="session")
def S01SIWOCN_MAPPING(MAPPING_FOLDER: str):
    """Path to a S1 OCN IW 1 mapping"""
    return os.path.join(MAPPING_FOLDER, "S01SIWOCN_pv1.0.0_mv1.0.0.json")


@pytest.fixture(scope="session")
def S01SSMOCN_MAPPING(MAPPING_FOLDER: str):
    """Path to a S1 OCN SM 1 mapping"""
    return os.path.join(MAPPING_FOLDER, "S01SSMOCN_pv1.0.0_mv1.0.0.json")


@pytest.fixture(scope="session")
def S02MSIL0__MAPPING(MAPPING_FOLDER: str):
    """Path to a S2 Level 0 mapping"""
    return os.path.join(MAPPING_FOLDER, "S02MSIL0__pv1.0.0_mv1.0.0.json")


@pytest.fixture(scope="session")
def S02MSIL1C_MAPPING(MAPPING_FOLDER: str):
    """Path to a S2 MSIL1C mapping"""
    return os.path.join(MAPPING_FOLDER, "S02MSIL1C_PSD14_pv1.0.0_mv1.0.0.json")


@pytest.fixture(scope="session")
def S02MSIL2A_PSD14_MAPPING(MAPPING_FOLDER: str):
    """Path to a S2 MSIL2A mapping"""
    return os.path.join(MAPPING_FOLDER, "S02MSIL2A_PSD14_pv1.0.0_mv1.0.0.json")


@pytest.fixture(scope="session")
def S02MSIL2A_PSD15_MAPPING(MAPPING_FOLDER: str):
    """Path to a S2 MSIL2A mapping"""
    return os.path.join(MAPPING_FOLDER, "S02MSIL2A_PSD15_pv1.0.0_mv1.0.0.json")


@pytest.fixture(scope="session")
def S03OLCL0__MAPPING(MAPPING_FOLDER: str):
    """Path to a S3 LEVEL 0 mapping"""
    print("\nS3_L0_OLC__MAPPING = ")

    return os.path.join(MAPPING_FOLDER, "S03OLCL0__pv1.0.0_mv1.0.0.json")


@pytest.fixture(scope="session")
def S03SLSL0__MAPPING(MAPPING_FOLDER: str):
    """Path to a S3 LEVEL 0 mapping"""
    print("\nS3_L0_SLS_MAPPING = ")

    return os.path.join(MAPPING_FOLDER, "S03SLSL0__pv1.0.0_mv1.0.0.json")


@pytest.fixture(scope="session")
def S03MWRL0__MAPPING(MAPPING_FOLDER: str):
    """Path to a S3 LEVEL 0 mapping"""
    print("\nS3_L0_MW__MAPPING = ")

    return os.path.join(MAPPING_FOLDER, "S03MWRL0__pv1.0.0_mv1.0.0.json")


@pytest.fixture(scope="session")
def S03SRAL0__MAPPING(MAPPING_FOLDER: str):
    """Path to a S3 SR  0 mapping"""
    print("\nS3_L0_RAL_MAPPING = ")

    return os.path.join(MAPPING_FOLDER, "S03SRAL0__pv1.0.0_mv1.0.0.json")


@pytest.fixture(scope="session")
def S03OLCERR_MAPPING(MAPPING_FOLDER: str):
    """Path to a S3 OL LEVEL 1 ERR mapping"""
    return os.path.join(MAPPING_FOLDER, "S03OLCERR_pv1.0.0_mv1.0.0.json")


@pytest.fixture(scope="session")
def S03OLCEFR_MAPPING(MAPPING_FOLDER: str):
    """Path to a S3 OL LEVEL 1 mapping"""
    return os.path.join(MAPPING_FOLDER, "S03OLCEFR_pv1.0.0_mv1.0.0.json")


@pytest.fixture(scope="session")
def S03OLCLFR_MAPPING(MAPPING_FOLDER: str):
    """Path to a S3 OL LEVEL 1 mapping"""
    return os.path.join(MAPPING_FOLDER, "S03OLCLFR_pv1.0.0_mv1.0.0.json")


@pytest.fixture(scope="session")
def S03SLSRBT_MAPPING(MAPPING_FOLDER: str):
    """Path to a S3 SL 1 RBT mapping"""
    return os.path.join(MAPPING_FOLDER, "S03SLSRBT_pv1.0.0_mv1.0.0.json")


@pytest.fixture(scope="session")
def S3SLSFRP_MAPPING(MAPPING_FOLDER: str):
    """Path to a S3 SL 2 FRP mapping"""
    return os.path.join(MAPPING_FOLDER, "S03SLSFRP_pv1.0.0_mv1.0.0.json")


@pytest.fixture(scope="session")
def S03SLSLST_MAPPING(MAPPING_FOLDER: str):
    """Path to a S3 SL 2 LST mapping"""
    return os.path.join(MAPPING_FOLDER, "S03SLSLST_pv1.0.0_mv1.0.0.json")


@pytest.fixture(scope="session")
def S03SYNSDR_MAPPING(MAPPING_FOLDER: str):
    """Path to a S3 SY 2 SYN mapping"""
    return os.path.join(MAPPING_FOLDER, "S03SYNSDR_pv1.0.0_mv1.0.0.json")


@pytest.fixture(scope="session")
def S03SRAL1A_MAPPING(MAPPING_FOLDER: str):
    """Path to a S3 SR 1 SRA mapping"""
    return os.path.join(MAPPING_FOLDER, "S03SRAL1A_pv1.0.0_mv1.0.0.json")


@pytest.fixture(scope="session")
def S03ALTL2H_MAPPING(MAPPING_FOLDER: str):
    """Path to a S3 SR 2 LAN mapping"""
    return os.path.join(MAPPING_FOLDER, "S03ALTL2H_pv1.0.0_mv1.0.0.json")


@pytest.fixture
def TEST_MAPPING(MAPPING_FOLDER: str):
    """Path to the S3 OL LEVEL 1 mapping"""
    return os.path.join(MAPPING_FOLDER, "S03OLCEFR_pv1.0.0_mv1.0.0.json")


@pytest.fixture
def TEST_DATA_SECRET(OUTPUT_DIR, s3_output_config_real):
    test_data_secret = {"test_data": s3_output_config_real}
    with (AnyPath.cast(OUTPUT_DIR) / "test_data_secret.json").open("w") as f:
        json.dump(test_data_secret, f)
    secret_provider = FileSecretStore(os.path.join(OUTPUT_DIR, "test_data_secret.json"))
    SecretsManager().add_provider(secret_provider)
    return AnyPath.cast(OUTPUT_DIR) / "test_data_secret.json"


@pytest.fixture
def TEST_DATA_FAKE_SECRET(OUTPUT_DIR, s3_config_fake):
    test_data_secret = {"test_data": s3_config_fake}
    with (AnyPath.cast(OUTPUT_DIR) / "test_data_fake_secret.json").open("w") as f:
        json.dump(test_data_secret, f)
    secret_provider = FileSecretStore(os.path.join(OUTPUT_DIR, "test_data_fake_secret.json"))
    SecretsManager().add_provider(secret_provider)
    return AnyPath.cast(OUTPUT_DIR) / "test_data_fake_secret.json"


# ---- Indirect mapping resolution ---

@pytest.fixture
def product_path(request) -> str:
    return request.getfixturevalue(request.param)


@pytest.fixture
def mapping_path(request) -> str:
    return request.getfixturevalue(request.param)
