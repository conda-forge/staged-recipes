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
import os
import shutil
import uuid
from contextlib import nullcontext
from functools import cache
from importlib.util import find_spec
from pathlib import Path

import numpy as np
import pytest
import xarray as xr
import yaml
from xarray import DataTree

from eopf.common.constants import EOCONTAINER_CATEGORY, EOPRODUCT_CATEGORY
from eopf.logging import configure_logging_from_directory, reset_logging
from eopf.product.conveniences import init_datatree
from tests.conftest import PARENT_DATA_PATH
from tests.test_utils import glob_fixture

# ----------------------------------#
# --- pytest command line options --#
# ----------------------------------#
TRIGGER_TEMPLATE_PATH = os.path.join(
    PARENT_DATA_PATH,
    "eopf",
    "triggering",
    "example",
    "trigger.yaml",
)

MAPPING_PATH = os.path.join(PARENT_DATA_PATH, "eopf", "ut/store", "mapping")


@cache
def _has_dask() -> bool:
    return find_spec("dask") is not None


def _require_dask() -> None:
    if not _has_dask():
        pytest.skip("requires dask")


@cache
def _dask_array_module():
    _require_dask()
    import dask.array as da

    return da


def _ones_array(shape: tuple[int, int], chunks: tuple[int, int]):
    if _has_dask():
        return _dask_array_module().ones(shape, chunks=chunks)

    return np.ones(shape)


@cache
def _dask_config_module():
    _require_dask()
    import dask.config

    return dask.config


def _reset_dask_scheduler() -> None:
    if not _has_dask():
        return

    _dask_config_module().set(scheduler=None)


@cache
def _dask_context_api():
    _require_dask()
    from eopf.dask_utils.dask_cluster_type import ClusterType
    from eopf.dask_utils.dask_context_manager import DaskContext
    from eopf.dask_utils.dask_context_utils import init_from_eo_configuration

    return ClusterType, DaskContext, init_from_eo_configuration


@cache
def _print_dask_client_cluster_info_fn():
    _require_dask()
    from eopf.dask_utils.dask_logging import print_dask_client_cluster_info

    return print_dask_client_cluster_info


def _print_dask_client_cluster_info(client):
    _print_dask_client_cluster_info_fn()(client)


def _drop_dask_payload(data: dict) -> None:
    data.pop("context_managers", None)
    data.pop("dask_config", None)
    data.get("general_configuration", {}).pop("dask__export_graphs", None)


@pytest.fixture(scope="session")
def EMBEDED_TEST_DATA_FOLDER_UNIT():
    """Path to test data folder"""
    out = Path(os.path.join(PARENT_DATA_PATH, "tests", "ut/data"))
    assert out.exists()
    return out


# Product searcch fixtures


@glob_fixture("S2*_MSIL2A*.SAFE", with_protocol=False)
def S2_MSIL2A_unit(path: str):
    """Path to a S2 MSIL2A LEVEL 2 product"""
    return path


@glob_fixture("S3*_OL_1_EFR*[!.zarr][!.SAFE].zip", protocols=["zip"])
def S3_OL_1_ZIP_unit(path: str):
    """Path to a S3 OL LEVEL 1 product"""
    return path


@glob_fixture("S3*_OL_1_ERR*.SEN3")
def S3_OL_1_unit(path: str):
    """Path to a S3 OL LEVEL 1 product"""
    return path


@pytest.fixture
def FAKE_S2_MSIL0_unit(EMBEDED_TEST_DATA_FOLDER_UNIT):
    return os.path.join(
        EMBEDED_TEST_DATA_FOLDER_UNIT,
        "FAKE",
        "S2B_OPER_MSI_L0__DS_2BPS_20221223T230531_S20221223T220352_N05.09",
    )


@pytest.fixture
def FAKE_S1_IW_SLC_unit(EMBEDED_TEST_DATA_FOLDER_UNIT):
    return os.path.join(
        EMBEDED_TEST_DATA_FOLDER_UNIT,
        "FAKE",
        "S1A_IW_SLC__1SDV_20240926T060410_20240926T060432_055832_06D2A3_30C8.SAFE",
    )


# ----------------------------------#
# ---------   TRIGGERING  ----------#
# ----------------------------------#
@pytest.fixture
def setup_triggering(EMBEDED_TEST_DATA_FOLDER_UNIT):
    # Inject into venv
    os.environ["EOPF_ROOT"] = os.path.join(PARENT_DATA_PATH, "eopf")
    os.environ["EOPF_CONFIG"] = str(EMBEDED_TEST_DATA_FOLDER_UNIT / "config")


@pytest.fixture
def TRIGGER_YAML_HEAVY_FILE_FILLED(
    request,
    EMBEDED_TEST_DATA_FOLDER_UNIT,
    FOLDER_WITH_LOGGING_CONFIGS,
    FOLDER_WITH_CONFIGS,
    OUTPUT_DIR,
    setup_triggering,
):
    _require_dask()
    trigger_filename = "trigger-heavy.yaml"
    image_config = getattr(request, "param", None)
    if isinstance(image_config, str):
        trigger_filename = image_config
        image_config = None
    elif isinstance(image_config, dict) and "trigger_filename" in image_config:
        image_config = dict(image_config)
        trigger_filename = image_config.pop("trigger_filename")
    filepath = os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "triggering", trigger_filename)
    with open(filepath) as f:
        data = yaml.safe_load(f)

    if image_config is not None:
        data["workflow"][0].setdefault("parameters", {}).update(image_config)

    for output_product in data["io"]["output_products"]:
        output_product["path"] = os.path.join(OUTPUT_DIR, output_product["path"])
    data["context_managers"] = [
        {
            "module": "eopf.dask_utils.dask_context_manager",
            "context_manager": "DaskContext",
            "parameters": {
                "cluster_type": "local",
                "cluster_config": {"processes": True, "threads_per_worker": 4},
                "client_config": {},
                "forward_worker_logger": "distributed.worker",
                "forward_worker_logger_level": logging.INFO,
            },
        },
    ]
    data["dask_config"] = {
        "temporary-directory": OUTPUT_DIR,
        "distributed.worker.local_directory": OUTPUT_DIR,
    }
    data["general_configuration"]["logging__dask_level"] = "DEBUG"
    data["config"][0] = os.path.join(FOLDER_WITH_CONFIGS, "eopf.toml")
    data["logging"] = [
        os.path.join(FOLDER_WITH_LOGGING_CONFIGS, "eopf.json"),
        os.path.join(FOLDER_WITH_LOGGING_CONFIGS, "dask.yaml"),
    ]
    data["eoqc"] = {
        "config_folders": [os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "qualitycontrol")],
    }
    output_name = os.path.join(OUTPUT_DIR, trigger_filename)
    with open(output_name, mode="w") as f:
        yaml.safe_dump(data, f)

    return output_name


@pytest.fixture
def TRIGGER_YAML_FILE_FILLED(
    EMBEDED_TEST_DATA_FOLDER_UNIT,
    FOLDER_WITH_LOGGING_CONFIGS,
    FOLDER_WITH_CONFIGS,
    OUTPUT_DIR,
    S2_MSIL2A_unit,
    setup_triggering,
):
    trigger_filename = "trigger.yaml"
    data, used_output_dir = fill_triggering_yaml(
        EMBEDED_TEST_DATA_FOLDER_UNIT,
        FOLDER_WITH_CONFIGS,
        FOLDER_WITH_LOGGING_CONFIGS,
        OUTPUT_DIR,
        S2_MSIL2A_unit,
        trigger_filename,
    )
    output_name = os.path.join(used_output_dir, trigger_filename)
    with open(output_name, mode="w") as f:
        yaml.safe_dump(data, f)
    return output_name


@pytest.fixture
def TRIGGER_YAML_ERROR_FILE_FILLED(
    EMBEDED_TEST_DATA_FOLDER_UNIT,
    FOLDER_WITH_LOGGING_CONFIGS,
    FOLDER_WITH_CONFIGS,
    OUTPUT_DIR,
    S2_MSIL2A_unit,
    setup_triggering,
):
    trigger_filename = "trigger_error.yaml"
    data, used_output_dir = fill_triggering_yaml(
        EMBEDED_TEST_DATA_FOLDER_UNIT,
        FOLDER_WITH_CONFIGS,
        FOLDER_WITH_LOGGING_CONFIGS,
        OUTPUT_DIR,
        S2_MSIL2A_unit,
        trigger_filename,
    )
    output_name = os.path.join(used_output_dir, trigger_filename)
    with open(output_name, mode="w") as f:
        yaml.safe_dump(data, f)
    return output_name


@pytest.fixture
def TRIGGER_YAML_BAD_OPEN_FILE_FILLED(
    EMBEDED_TEST_DATA_FOLDER_UNIT,
    FOLDER_WITH_LOGGING_CONFIGS,
    FOLDER_WITH_CONFIGS,
    OUTPUT_DIR,
    S2_MSIL2A_unit,
    setup_triggering,
):
    trigger_filename = "trigger_bad_open.yaml"
    data, used_output_dir = fill_triggering_yaml(
        EMBEDED_TEST_DATA_FOLDER_UNIT,
        FOLDER_WITH_CONFIGS,
        FOLDER_WITH_LOGGING_CONFIGS,
        OUTPUT_DIR,
        S2_MSIL2A_unit,
        trigger_filename,
    )
    output_name = os.path.join(used_output_dir, trigger_filename)
    with open(output_name, mode="w") as f:
        yaml.safe_dump(data, f)
    return output_name


@pytest.fixture
def TRIGGER_YAML_NOT_ACCEPTED_OPEN_FILE_FILLED(
    EMBEDED_TEST_DATA_FOLDER_UNIT,
    FOLDER_WITH_LOGGING_CONFIGS,
    FOLDER_WITH_CONFIGS,
    OUTPUT_DIR,
    S2_MSIL2A_unit,
    setup_triggering,
):
    trigger_filename = "trigger_not_accepted_open.yaml"
    data, used_output_dir = fill_triggering_yaml(
        EMBEDED_TEST_DATA_FOLDER_UNIT,
        FOLDER_WITH_CONFIGS,
        FOLDER_WITH_LOGGING_CONFIGS,
        OUTPUT_DIR,
        S2_MSIL2A_unit,
        trigger_filename,
    )
    output_name = os.path.join(used_output_dir, trigger_filename)
    with open(output_name, mode="w") as f:
        yaml.safe_dump(data, f)
    return output_name


@pytest.fixture
def TRIGGER_YAML_RELATIVE_FILLED(
    EMBEDED_TEST_DATA_FOLDER_UNIT,
    FOLDER_WITH_LOGGING_CONFIGS,
    FOLDER_WITH_CONFIGS,
    OUTPUT_DIR,
    S2_MSIL2A_unit,
    setup_triggering,
):
    trigger_filename = "trigger.yaml"
    data, used_output_dir = fill_triggering_yaml(
        EMBEDED_TEST_DATA_FOLDER_UNIT,
        FOLDER_WITH_CONFIGS,
        FOLDER_WITH_LOGGING_CONFIGS,
        OUTPUT_DIR,
        S2_MSIL2A_unit,
        trigger_filename,
        relative=True,
    )
    output_name = os.path.join(used_output_dir, trigger_filename)
    with open(output_name, mode="w") as f:
        yaml.safe_dump(data, f)
    return output_name, used_output_dir


def fill_triggering_yaml(
    EMBEDED_TEST_DATA_FOLDER,
    FOLDER_WITH_CONFIGS,
    FOLDER_WITH_LOGGING_CONFIGS,
    OUTPUT_DIR,
    S2_MSIL2A_unit,
    trigger_filename,
    relative=False,
):
    # ToDO construc blosc from bloscdesc
    used_output_dir = os.path.join(
        OUTPUT_DIR,
        os.path.splitext(os.path.basename(trigger_filename))[0],
    )
    os.makedirs(used_output_dir, exist_ok=True)
    filepath = os.path.join(EMBEDED_TEST_DATA_FOLDER, "triggering", trigger_filename)
    with open(filepath) as f:
        data = yaml.safe_load(f)
    _drop_dask_payload(data)

    data["io"]["input_products"][0]["path"] = S2_MSIL2A_unit
    if not relative:
        data["io"]["output_products"][0]["path"] = os.path.join(
            used_output_dir,
            data["io"]["output_products"][0]["path"],
        )
        data["io"]["output_products"][1]["path"] = os.path.join(
            used_output_dir,
            data["io"]["output_products"][1]["path"],
        )
        data["breakpoints"]["folder"] = os.path.join(
            used_output_dir,
            data["breakpoints"]["folder"],
        )
    else:
        data["io"]["output_products"][0]["path"] = os.path.join(
            "../it",
            data["io"]["output_products"][0]["path"],
        )
        data["io"]["output_products"][1]["path"] = os.path.join(
            "../it",
            data["io"]["output_products"][1]["path"],
        )
        data["breakpoints"]["folder"] = os.path.join(
            "../it",
            data["breakpoints"]["folder"],
        )

    if relative:
        data["config"][0] = "./eopf.toml"
        data["logging"][0] = "./eopf.json"
        shutil.copy(os.path.join(FOLDER_WITH_CONFIGS, "eopf.toml"), used_output_dir)
        shutil.copy(
            os.path.join(FOLDER_WITH_LOGGING_CONFIGS, "eopf.json"),
            used_output_dir,
        )
    else:
        data["config"][0] = os.path.join(FOLDER_WITH_CONFIGS, "eopf.toml")
        data["logging"][0] = os.path.join(FOLDER_WITH_LOGGING_CONFIGS, "eopf.json")
    data["eoqc"] = {
        "config_folders": [os.path.join(EMBEDED_TEST_DATA_FOLDER, "qualitycontrol")],
    }
    return data, used_output_dir


@pytest.fixture
def TRIGGER_YAML_ERROR_BEST_EFFORT_FILE_FILLED(
    EMBEDED_TEST_DATA_FOLDER_UNIT,
    FOLDER_WITH_LOGGING_CONFIGS,
    FOLDER_WITH_CONFIGS,
    OUTPUT_DIR,
    S2_MSIL2A_unit,
    setup_triggering,
):
    trigger_filename = "trigger_error.yaml"
    data, used_output_dir = fill_triggering_yaml(
        EMBEDED_TEST_DATA_FOLDER_UNIT,
        FOLDER_WITH_CONFIGS,
        FOLDER_WITH_LOGGING_CONFIGS,
        OUTPUT_DIR,
        S2_MSIL2A_unit,
        trigger_filename,
    )
    data["general_configuration"]["triggering__error_policy"] = "BEST_EFFORT"
    output_name = os.path.join(used_output_dir, trigger_filename)
    with open(output_name, mode="w") as f:
        yaml.safe_dump(data, f)
    return output_name


@pytest.fixture
def TRIGGER_YAML_ERROR_CRITICAL_FILE_FILLED(
    EMBEDED_TEST_DATA_FOLDER_UNIT,
    FOLDER_WITH_LOGGING_CONFIGS,
    FOLDER_WITH_CONFIGS,
    OUTPUT_DIR,
    S2_MSIL2A_unit,
    setup_triggering,
):
    trigger_filename = "trigger_error.yaml"
    data, used_output_dir = fill_triggering_yaml(
        EMBEDED_TEST_DATA_FOLDER_UNIT,
        FOLDER_WITH_CONFIGS,
        FOLDER_WITH_LOGGING_CONFIGS,
        OUTPUT_DIR,
        S2_MSIL2A_unit,
        trigger_filename,
    )
    data["general_configuration"]["triggering__error_policy"] = "FAIL_ON_CRITICAL"
    output_name = os.path.join(used_output_dir, trigger_filename)
    with open(output_name, mode="w") as f:
        yaml.safe_dump(data, f)

    return output_name


@pytest.fixture
def TRIGGER_YAML_REGEX_FILE_FILLED(
    EMBEDED_TEST_DATA_FOLDER_UNIT,
    FOLDER_WITH_LOGGING_CONFIGS,
    FOLDER_WITH_CONFIGS,
    OUTPUT_DIR,
    S2_MSIL2A_unit,
    setup_triggering,
    INPUT_DIR,
):
    trigger_filename = "trigger.yaml"
    data, used_output_dir = fill_triggering_yaml(
        EMBEDED_TEST_DATA_FOLDER_UNIT,
        FOLDER_WITH_CONFIGS,
        FOLDER_WITH_LOGGING_CONFIGS,
        OUTPUT_DIR,
        S2_MSIL2A_unit,
        trigger_filename,
    )
    data["io"]["input_products"][0]["path"] = INPUT_DIR
    data["io"]["input_products"][0].update(
        {
            "regex": r"S2.*_MSIL2A.*\.SAFE",
            "multiplicity": "exactly_one",
        },
    )
    data["io"]["input_products"][0]["engine"] = "safe"
    data["io"]["input_products"][0]["type"] = "regex"
    output_name = os.path.join(used_output_dir, trigger_filename)
    with open(output_name, mode="w") as f:
        yaml.safe_dump(data, f)

    return output_name


@pytest.fixture
def TRIGGER_YAML_DATATREE_FILE_FILLED(
    EMBEDED_TEST_DATA_FOLDER_UNIT,
    FOLDER_WITH_LOGGING_CONFIGS,
    FOLDER_WITH_CONFIGS,
    OUTPUT_DIR,
    S2_MSIL2A_unit,
    setup_triggering,
):
    trigger_filename = "trigger.yaml"
    data, used_output_dir = fill_triggering_yaml(
        EMBEDED_TEST_DATA_FOLDER_UNIT,
        FOLDER_WITH_CONFIGS,
        FOLDER_WITH_LOGGING_CONFIGS,
        OUTPUT_DIR,
        S2_MSIL2A_unit,
        trigger_filename,
    )
    data["general_configuration"]["triggering__use_datatree"] = True
    data["general_configuration"]["triggering__validate_run"] = True
    data["general_configuration"]["triggering__use_default_filename"] = True
    data["io"]["input_products"][0]["path"] = S2_MSIL2A_unit
    data["io"]["output_products"][0]["path"] = os.path.join(
        used_output_dir,
        data["io"]["output_products"][0]["path"],
    )
    data["io"]["output_products"][0]["opening_mode"] = "w-"
    data["io"]["output_products"][1]["path"] = os.path.join(
        used_output_dir,
        data["io"]["output_products"][1]["path"],
    )
    data["io"]["output_products"][1]["opening_mode"] = "w-"
    data["breakpoints"]["folder"] = os.path.join(
        used_output_dir,
        data["breakpoints"]["folder"] + "_datatree",
    )
    output_name = os.path.join(used_output_dir, trigger_filename)
    with open(output_name, mode="w") as f:
        yaml.safe_dump(data, f)
    return output_name


@pytest.fixture
def TRIGGER_YAML_CONTAINER_FILE_FILLED(
    EMBEDED_TEST_DATA_FOLDER_UNIT,
    FOLDER_WITH_LOGGING_CONFIGS,
    FOLDER_WITH_CONFIGS,
    OUTPUT_DIR,
    S2_MSIL2A_unit,
    setup_triggering,
):
    trigger_filename = "trigger_container.yaml"
    data, used_output_dir = fill_triggering_yaml(
        EMBEDED_TEST_DATA_FOLDER_UNIT,
        FOLDER_WITH_CONFIGS,
        FOLDER_WITH_LOGGING_CONFIGS,
        OUTPUT_DIR,
        S2_MSIL2A_unit,
        trigger_filename,
    )
    data["breakpoints"]["folder"] = os.path.join(
        used_output_dir,
        data["breakpoints"]["folder"] + "_container",
    )
    output_name = os.path.join(used_output_dir, trigger_filename)
    with open(output_name, mode="w") as f:
        yaml.safe_dump(data, f)

    return output_name


@pytest.fixture
def TRIGGER_YAML_S3_FILE_FILLED(
    EMBEDED_TEST_DATA_FOLDER_UNIT,
    FOLDER_WITH_LOGGING_CONFIGS,
    FOLDER_WITH_CONFIGS,
    OUTPUT_DIR,
    S2_MSIL2A_unit,
    setup_triggering,
    s3_test_data,
    s3_output_test_data,
    s3_config_real,
    s3_output_config_real,
):
    trigger_filename = "trigger.yaml"
    data, used_output_dir = fill_triggering_yaml(
        EMBEDED_TEST_DATA_FOLDER_UNIT,
        FOLDER_WITH_CONFIGS,
        FOLDER_WITH_LOGGING_CONFIGS,
        OUTPUT_DIR,
        S2_MSIL2A_unit,
        trigger_filename,
    )
    data["io"]["input_products"][0]["path"] = f"{s3_test_data[0]}://{s3_test_data[1]}"
    data["io"]["input_products"][0].update(
        {
            "type": "regex",
            "regex": "olci_zarr_test.zarr",
            "multiplicity": "exactly_one",
        },
    )
    data["io"]["input_products"][0]["reader_params"] = {
        "storage_options": s3_config_real,
    }
    data["io"]["input_products"][0]["engine"] = "cpm_zarr"
    data["io"]["output_products"][0]["path"] = (
        f"{s3_output_test_data[0]}://{s3_output_test_data[1]}/{str(uuid.uuid4())}/olci_zarr_test_cpy_trigg.zarr"
    )
    data["io"]["input_products"][0]["writer_params"] = {
        "storage_options": s3_output_config_real,
    }
    data["breakpoints"]["folder"] = os.path.join(
        used_output_dir,
        data["breakpoints"]["folder"],
    )
    data["io"]["output_products"][0]["writer_params"] = {
        "storage_options": s3_output_config_real,
    }
    data["io"]["output_products"][0]["opening_mode"] = "w"
    output_name = os.path.join(used_output_dir, "triggers3.yaml")
    with open(output_name, mode="w") as f:
        yaml.safe_dump(data, f)

    return output_name


@pytest.fixture
def TRIGGER_YAML_TEMPLATE(
    TEST_DATA_FAKE_SECRET,
    setup_triggering,
):
    return TRIGGER_TEMPLATE_PATH


@pytest.fixture(scope="module")
def FOLDER_WITH_CONFIGS(EMBEDED_TEST_DATA_FOLDER_UNIT):
    return os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "config")


@pytest.fixture(scope="module")
def FOLDER_WITH_LOGGING_CONFIGS(EMBEDED_TEST_DATA_FOLDER_UNIT):
    return os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "logging")


@pytest.fixture(autouse=True, scope="function")
def setup_log_and_conf_unit(
    request,
    FOLDER_WITH_CONFIGS,
    FOLDER_WITH_LOGGING_CONFIGS,
    EMBEDED_TEST_DATA_FOLDER_UNIT,
):
    if "no_autouse_fixture" in request.keywords:
        # Skip applying the fixture for this test
        yield
        return
    print("Start log and conf setup")
    from eopf.config.config import EOConfiguration

    # Deactivate automatic 'dask.distributed' scheduler search as this one is deactivated
    _reset_dask_scheduler()
    conf = EOConfiguration()
    conf.clear_loaded_configurations()
    # TODO : These have been added by the conf test, unregister requirement param might be needed at some point
    conf["foo2"] = "truc"
    conf["foonodefaults"] = "machin"
    conf["foo1"] = "truc"
    # EOConfiguration does not load the installed default file implicitly.
    # Unit tests use the embedded test configuration explicitly.
    conf.load_file(os.path.join(FOLDER_WITH_CONFIGS, "eopf.toml"))
    conf["logging__level"] = "DEBUG"
    # conf.register_requested_parameter(
    #    "qualitycontrol__folder",
    #    os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "qualitycontrol"),
    # )
    conf.register_requested_parameter(
        "model__folder",
        default_value=os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "product", "models"),
    )
    conf["model__folder"] = os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "product", "models")
    conf.register_requested_parameter(
        "dask_utils__compute__step",
        9999,
        True,
        description="Number of dask future computed simultaneously in dask_utils",
    )
    reset_logging()
    configure_logging_from_directory(FOLDER_WITH_LOGGING_CONFIGS, mandatory=True)
    logging.getLogger("eopf")

    print(f"Available conf : {conf.param_list_available}")

    yield

    conf.clear_loaded_configurations()

    reset_logging()
    print("Finished log and conf setup")


@pytest.fixture(scope="function")
def dask_context(
    setup_log_and_conf_unit,
    FOLDER_WITH_CONFIGS,
    FOLDER_WITH_LOGGING_CONFIGS,
    EMBEDED_TEST_DATA_FOLDER_UNIT,
):
    if not _has_dask():
        with nullcontext() as ctx:
            yield ctx
        return

    import dask.config

    with dask.config.set(scheduler="threads"):
        yield None
    # Deactivate automatic 'dask.distributed' scheduler search as this one is deactivated
    _reset_dask_scheduler()


@pytest.fixture(scope="function")
def dask_context_processes(
    setup_log_and_conf_unit,
    FOLDER_WITH_CONFIGS,
    FOLDER_WITH_LOGGING_CONFIGS,
    EMBEDED_TEST_DATA_FOLDER_UNIT,
):
    if not _has_dask():
        with nullcontext() as ctx:
            yield ctx
        return

    ClusterType, DaskContext, _ = _dask_context_api()
    with DaskContext(
        cluster_type=ClusterType.LOCAL,
        cluster_config={
            "processes": True,
            "n_workers": 2,
            "threads_per_worker": 1,
            "scheduler_port": 0,
            "dashboard_address": 0,  # random dashboard port
        },
    ) as ctx:
        print(f"DASK Context : {ctx}")
        _print_dask_client_cluster_info(ctx.client)
        yield ctx

    # Deactivate automatic 'dask.distributed' scheduler search as this one is deactivated
    _reset_dask_scheduler()


@pytest.fixture(scope="function")
def dask_context_threads(
    setup_log_and_conf_unit,
    FOLDER_WITH_CONFIGS,
    FOLDER_WITH_LOGGING_CONFIGS,
    EMBEDED_TEST_DATA_FOLDER_UNIT,
):
    if not _has_dask():
        with nullcontext() as ctx:
            yield ctx
        return

    ClusterType, DaskContext, _ = _dask_context_api()
    with DaskContext(
        cluster_type=ClusterType.LOCAL,
        cluster_config={
            "processes": False,
            "n_workers": 1,
            "threads_per_worker": 4,
            "dashboard_address": None,
        },
    ) as ctx:
        print(f"DASK Context : {ctx}")
        _print_dask_client_cluster_info(ctx.client)
        yield ctx

    # Deactivate automatic 'dask.distributed' scheduler search as this one is deactivated
    _reset_dask_scheduler()


@pytest.fixture(scope="function")
def dask_gateway_context(
    setup_log_and_conf_unit,
    FOLDER_WITH_CONFIGS,
    FOLDER_WITH_LOGGING_CONFIGS,
    EMBEDED_TEST_DATA_FOLDER_UNIT,
):
    if not _has_dask():
        with nullcontext() as ctx:
            yield ctx
        return

    ClusterType, DaskContext, _ = _dask_context_api()
    dask_gateway_address = os.getenv("DASK_GATEWAY__ADDRESS")
    jupyterhub_api_token = os.getenv("JUPYTERHUB_API_TOKEN")

    if dask_gateway_address is None or jupyterhub_api_token is None:
        raise Exception("Missing DASK_GATEWAY__ADDRESS or JUPYTERHUB_API_TOKEN")

    with DaskContext(
        cluster_type=ClusterType.GATEWAY,
        cluster_config={
            "address": dask_gateway_address,
            "auth": {"type": "jupyterhub", "api_token": jupyterhub_api_token},
            "image": "registry.eopf.copernicus.eu/cpm/eopf-cpm:latest",
            "worker_memory": 4,
            "n_workers": 8,
            "scheduler_port": 0,
            "dashboard_address": 0,  # random dashboard port
        },
        client_config={"timeout": "320s"},
        connect_timeout=60,
    ) as ctx:
        print(f"DASK Context : {ctx}")
        yield ctx
    # Deactivate automatic 'dask.distributed' scheduler search as this one is deactivated
    _reset_dask_scheduler()


@pytest.fixture
def fake_quality_product():
    product = init_datatree("test")
    product.attrs.setdefault("stac_discovery", {}).setdefault("properties", {})["product:type"] = "FAKEONE"
    product["measurements/radiance/oa01_radiance"] = _ones_array((1000, 1000), (250, 250)) * 2048
    product["measurements/radiance/oa01_radiance"].attrs["long_name"] = "truc"
    product["measurements/radiance/oa01_radiance"].attrs["short_name"] = "oa01_radiance"
    product["measurements/radiance/oa01_radiance"].attrs["dtype"] = "truc"
    # need to set it to data to make the exact comparison
    product["measurements/radiance/oa01_radiance"].data.attrs["long_name"] = "truc"
    product["measurements/radiance/oa01_radiance"].data.attrs["short_name"] = "oa01_radiance"
    product["measurements/radiance/oa01_radiance"].data.attrs["dtype"] = "truc"
    product["measurements/radiance/oa02_radiance"] = _ones_array((1000, 1000), (250, 250)) * 2048
    product["measurements/radiance/oa02_radiance"].attrs["long_name"] = "truc"
    product["measurements/radiance/oa02_radiance"].attrs["short_name"] = "oa02_radiance"
    product["measurements/radiance/oa02_radiance"].attrs["dtype"] = "truc"
    product["measurements/radiance/oa02_radiance"].data.attrs["long_name"] = "truc"
    product["measurements/radiance/oa02_radiance"].data.attrs["short_name"] = "oa02_radiance"
    product["measurements/radiance/oa02_radiance"].data.attrs["dtype"] = "truc"
    product["measurements/empty_group/empty"] = _ones_array((10, 10), (10, 10)) * 2048
    product["measurements/empty_group/empty"].attrs["long_name"] = "truc"
    product["measurements/empty_group/empty"].attrs["short_name"] = "truc"
    product["measurements/empty_group/empty"].attrs["dtype"] = "truc"
    product["measurements/empty_group/empty"].data.attrs["long_name"] = "truc"
    product["measurements/empty_group/empty"].data.attrs["short_name"] = "truc"
    product["measurements/empty_group/empty"].data.attrs["dtype"] = "truc"

    product.short_names = {
        "oa01_radiance": "measurements/radiance/oa01_radiance",
        "oa02_radiance": "measurements/radiance/oa02_radiance",
    }
    product.attrs["other_metadata"].update(
        {
            "radiance_coeff": 2.03,
            "absolute_orbit_number": 12,
            "datatake_type": "INS-NOBS",
        },
    )
    product.attrs["stac_discovery"] = {
        "type": "Feature",
        "stac_version": "1.1.0",
        "stac_extensions": [
            "https://cs-si.github.io/eopf-stac-extension/v1.2.0/schema.json",
            "https://stac-extensions.github.io/sat/v1.0.0/schema.json",
            "https://stac-extensions.github.io/product/v0.1.0/schema.json",
            "https://stac-extensions.github.io/processing/v1.2.0/schema.json",
        ],
        "id": "S3A_SL_2_LST____20220614T130003_20220614T130503_20220614T135543_0299_086_238",
        "geometry": {
            "coordinates": [
                [
                    [50.28376, -13.843143],
                    [47.965759, -13.308908],
                    [48.387905, -11.565237],
                    [50.69191, -12.0927],
                    [50.28376, -13.843143],
                ],
            ],
            "type": "Polygon",
        },
        "gsd": "1000",
        "bbox": [50.69191, -13.843143, 47.965759, -11.565237],
        "properties": {
            "collection": "004.06.00",
            "datetime": None,
            "start_datetime": "2022-06-14T13:00:43.45Z",
            "end_datetime": "2022-06-14T13:12:40.45Z",
            "created": "2022-06-14T13:57:37Z",
            "instruments": ["slstr"],
            "constellation": "sentinel-3",
            "product:timeliness_category": "NR",
            "mission": "copernicus",
            "platform": "sentinel-3A",
            "sat:anx_datetime": "2022-06-14T12:40:20.457854",
            "sat:absolute_orbit": 32936,
            "sat:relative_orbit": 238,
            "sat:orbit_state": "ascending",
            "sat:platform_international_designator": "2016-011A",
            "eopf:instrument_mode": "INS-NOBS",
            "eopf:datatake_id": "350542",
            "product:type": "FAKEONE",
            "product:timeliness": "PT1H30M",
            "processing:version": "1.1.0",
            "processing:datetime": "2022-06-14T13:57:37Z",
            "processing:facility": "ESA S3MPC",
            "processing:software": {"Sentinel-1 IPF": "002.71"},
            "processing:level": "L2",
            "providers": [
                {"name": "S3MPC", "roles": ["processor"]},
                {"name": "ACRI-ST", "roles": ["producer"]},
            ],
        },
        "links": [
            {"rel": "self", "href": "./.zattrs.json", "type": "application/json"},
        ],
        "assets": {},
    }

    product.attrs["other_metadata"]["integration_time"] = {}
    for b in (
        "b01",
        "b02",
        "b03",
        "b04",
        "b05",
        "b06",
        "b07",
        "b08",
        "B8a",
        "b09",
        "b10",
        "b11",
        "b12",
    ):
        product.attrs["other_metadata"]["integration_time"][b] = 1.30

    product.attrs["processing_history"] = {
        "Level-1 Product": [
            {
                "processor": "L1.1 processor",
                "version": "2.2",
                "facility": "ESA-ESRIN",
                "time": "2022-06-14T13:10:43.459284Z",
                "inputs": ["SXX_L0.SAFE"],
                "outputs": ["SXX_L1-1.SAFE"],
                "adfs": ["ADF_L1.SAFE"],
            },
            {
                "processor": "L1.2 processor",
                "version": "2.2",
                "facility": "ESA-ESRIN",
                "time": "2022-06-14T13:15:43.459284Z",
                "inputs": ["SXX_L1-1.SAFE"],
                "outputs": ["SXX_L1-2.SAFE"],
                "adfs": ["ADF_L1.SAFE"],
            },
        ],
        "Level-0 Product": [
            {
                "processor": "L0 processor",
                "version": "2.1",
                "facility": "ESA-ESRIN",
                "time": "2022-06-14T13:03:43.459284Z",
                "inputs": ["sat_data.SAFE"],
                "outputs": ["SXX_L0.SAFE"],
                "adfs": ["ADF_L0.SAFE"],
            },
        ],
    }
    return product


@pytest.fixture
def fake_quality_datatree():
    product = DataTree(name="test")
    product.product_type = "FAKEONE"
    # Create groups
    product["measurements"] = DataTree(name="measurements")
    product["measurements/radiance"] = DataTree(name="radiance")
    product["measurements/empty_group"] = DataTree(name="empty_group")

    # --- OA01 ---
    oa01 = xr.DataArray(
        _ones_array((1000, 1000), chunks=(250, 250)) * 2048,
        name="oa01_radiance",
    )
    oa01.attrs.update(
        {
            "long_name": "truc",
            "short_name": "oa01_radiance",
            "dtype": "truc",
        },
    )

    # --- OA02 ---
    oa02 = xr.DataArray(
        _ones_array((1000, 1000), chunks=(250, 250)) * 2048,
        name="oa02_radiance",
    )
    oa02.attrs.update(
        {
            "long_name": "truc",
            "short_name": "oa02_radiance",
            "dtype": "truc",
        },
    )

    # --- Empty group variable ---
    empty = xr.DataArray(
        _ones_array((10, 10), chunks=(10, 10)) * 2048,
        name="empty",
    )
    empty.attrs.update(
        {
            "long_name": "truc",
            "short_name": "truc",
            "dtype": "truc",
        },
    )

    product["measurements/radiance/oa01_radiance"] = oa01
    product["measurements/radiance/oa02_radiance"] = oa02
    product["measurements/empty_group/empty"] = empty

    product.attrs["other_metadata"] = {
        "radiance_coeff": 2.03,
        "absolute_orbit_number": 12,
        "datatake_type": "INS-NOBS",
        "eopf_category": "eoproduct",
    }
    product.attrs["stac_discovery"] = {
        "type": "Feature",
        "stac_version": "1.1.0",
        "stac_extensions": [
            "https://cs-si.github.io/eopf-stac-extension/v1.2.0/schema.json",
            "https://stac-extensions.github.io/sat/v1.0.0/schema.json",
            "https://stac-extensions.github.io/product/v0.1.0/schema.json",
            "https://stac-extensions.github.io/processing/v1.2.0/schema.json",
        ],
        "id": "S3A_SL_2_LST____20220614T130003_20220614T130503_20220614T135543_0299_086_238",
        "geometry": {
            "coordinates": [
                [
                    [50.28376, -13.843143],
                    [47.965759, -13.308908],
                    [48.387905, -11.565237],
                    [50.69191, -12.0927],
                    [50.28376, -13.843143],
                ],
            ],
            "type": "Polygon",
        },
        "gsd": "1000",
        "bbox": [50.69191, -13.843143, 47.965759, -11.565237],
        "properties": {
            "collection": "004.06.00",
            "datetime": None,
            "start_datetime": "2022-06-14T13:00:43.45Z",
            "end_datetime": "2022-06-14T13:12:40.45Z",
            "created": "2022-06-14T13:57:37Z",
            "instruments": ["slstr"],
            "constellation": "sentinel-3",
            "product:timeliness_category": "NR",
            "mission": "copernicus",
            "platform": "sentinel-3A",
            "sat:anx_datetime": "2022-06-14T12:40:20.457854",
            "sat:absolute_orbit": 32936,
            "sat:relative_orbit": 238,
            "sat:orbit_state": "ascending",
            "sat:platform_international_designator": "2016-011A",
            "eopf:instrument_mode": "INS-NOBS",
            "eopf:datatake_id": "350542",
            "product:type": "FAKEONE",
            "product:timeliness": "PT1H30M",
            "processing:version": "1.1.0",
            "processing:datetime": "2022-06-14T13:57:37Z",
            "processing:facility": "ESA S3MPC",
            "processing:software": {"Sentinel-1 IPF": "002.71"},
            "processing:level": "L2",
            "providers": [
                {"name": "S3MPC", "roles": ["processor"]},
                {"name": "ACRI-ST", "roles": ["producer"]},
            ],
        },
        "links": [
            {"rel": "self", "href": "./.zattrs.json", "type": "application/json"},
        ],
        "assets": {},
    }

    product.attrs["other_metadata"]["integration_time"] = {}
    for b in (
        "b01",
        "b02",
        "b03",
        "b04",
        "b05",
        "b06",
        "b07",
        "b08",
        "B8a",
        "b09",
        "b10",
        "b11",
        "b12",
    ):
        product.attrs["other_metadata"]["integration_time"][b] = 1.30

    product.attrs["processing_history"] = {
        "Level-1 Product": [
            {
                "processor": "L1.1 processor",
                "version": "2.2.0",
                "facility": "ESA-ESRIN",
                "time": "2022-06-14T13:15:43.459284Z",
                "inputs": ["SXX_L0.SAFE"],
                "outputs": ["SXX_L1-1.SAFE"],
                "adfs": ["ADF_L1.SAFE"],
            },
            {
                "processor": "L1.2 processor",
                "version": "2.2.0",
                "facility": "ESA-ESRIN",
                "time": "2022-06-14T13:10:43.459284Z",
                "inputs": ["SXX_L1-1.SAFE"],
                "outputs": ["SXX_L1-2.SAFE"],
                "adfs": ["ADF_L1.SAFE"],
            },
        ],
        "Level-0 Product": [
            {
                "processor": "L0 processor",
                "version": "2.1.0",
                "facility": "ESA-ESRIN",
                "time": "2022-06-14T13:03:43.459284Z",
                "inputs": ["sat_data.SAFE"],
                "outputs": ["SXX_L0.SAFE"],
                "adfs": ["ADF_L0.SAFE"],
            },
        ],
    }
    product.cpm.rebuild_short_names_from_tree()
    product.cpm.sort_processing_history()
    return product


@pytest.fixture
def fake_quality_repla_product(fake_quality_datatree):
    product = init_datatree("test")
    product.attrs = fake_quality_datatree.attrs.copy()
    product.cpm.product_type = "FAKEONEREPLA"
    return product


@pytest.fixture
def fake_quality_container(fake_quality_datatree):
    container = DataTree(name="testcont")
    container.cpm.product_kind == EOCONTAINER_CATEGORY
    container["subproduct"] = fake_quality_datatree
    container.attrs["stac_discovery"] = {
        "type": "Feature",
        "stac_version": "1.1.0",
        "stac_extensions": [
            "https://cs-si.github.io/eopf-stac-extension/v1.2.0/schema.json",
            "https://stac-extensions.github.io/sat/v1.0.0/schema.json",
            "https://stac-extensions.github.io/product/v0.1.0/schema.json",
            "https://stac-extensions.github.io/processing/v1.2.0/schema.json",
        ],
        "id": "S3A_SL_2_LST____20220614T130003_20220614T130503_20220614T135543_0299_086_238",
        "geometry": {
            "coordinates": [
                [
                    [50.28376, -13.843143],
                    [47.965759, -13.308908],
                    [48.387905, -11.565237],
                    [50.69191, -12.0927],
                ],
            ],
            "type": "Polygon",
        },
        "gsd": "1000",
        "bbox": [50.69191, -13.843143, 47.965759, -11.565237],
        "properties": {
            "collection": "004.06.00",
            "datetime": None,
            "start_datetime": "2022-06-14T13:00:43.45Z",
            "end_datetime": "2022-06-14T13:12:40.45Z",
            "created": "2022-06-14T13:57:37Z",
            "instruments": ["slstr"],
            "constellation": "sentinel-3",
            "mission": "copernicus",
            "platform": "sentinel-3A",
            "sat:anx_datetime": "2022-06-14T12:40:20.457854",
            "sat:absolute_orbit": 32936,
            "sat:relative_orbit": 238,
            "sat:orbit_state": "ascending",
            "sat:platform_international_designator": "2016-011A",
            "eopf:instrument_mode": "INS-NOBS",
            "eopf:datatake_id": "350542",
            "product:type": "FAKECONT",
            "product:timeliness": "PT1H30M",
            "processing:version": "1.1.0",
            "processing:datetime": "2022-06-14T13:57:37Z",
            "processing:facility": "ESA S3MPC",
            "processing:software": {"Sentinel-1 IPF": "002.71"},
            "processing:level": "L2",
            "providers": [
                {"name": "S3MPC", "roles": ["processor"]},
                {"name": "ACRI-ST", "roles": ["producer"]},
            ],
        },
        "links": [
            {"rel": "self", "href": "./.zattrs.json", "type": "application/json"},
        ],
        "assets": {},
    }

    container.cpm.product_kind = EOCONTAINER_CATEGORY
    container.cpm.product_type = "FAKECONT"

    container["subcont"] = DataTree(name="subconty")
    container["subcont"].cpm.product_type = "FAKECTONY"
    container["subcont"].cpm.product_kind = EOCONTAINER_CATEGORY
    container["subcont"].attrs["stac_discovery"] = {
        "type": "Feature",
        "stac_version": "1.1.0",
        "stac_extensions": [
            "https://cs-si.github.io/eopf-stac-extension/v1.2.0/schema.json",
            "https://stac-extensions.github.io/sat/v1.0.0/schema.json",
            "https://stac-extensions.github.io/product/v0.1.0/schema.json",
            "https://stac-extensions.github.io/processing/v1.2.0/schema.json",
        ],
        "id": "S3A_SL_2_LST____20220614T130003_20220614T130503_20220614T135543_0299_086_238",
        "geometry": {
            "coordinates": [
                [
                    [50.28376, -13.843143],
                    [47.965759, -13.308908],
                    [48.387905, -11.565237],
                    [50.69191, -12.0927],
                ],
            ],
            "type": "Polygon",
        },
        "gsd": "1000",
        "bbox": [50.69191, -13.843143, 47.965759, -11.565237],
        "properties": {
            "collection": "004.06.00",
            "datetime": None,
            "start_datetime": "2022-06-14T13:00:43.45Z",
            "end_datetime": "2022-06-14T13:12:40.45Z",
            "created": "2022-06-14T13:57:37Z",
            "instruments": ["slstr"],
            "constellation": "sentinel-3",
            "mission": "copernicus",
            "platform": "sentinel-3A",
            "sat:anx_datetime": "2022-06-14T12:40:20.457854",
            "sat:absolute_orbit": 32936,
            "sat:relative_orbit": 238,
            "sat:orbit_state": "ascending",
            "sat:platform_international_designator": "2016-011A",
            "eopf:instrument_mode": "INS-NOBS",
            "eopf:datatake_id": "350542",
            "product:type": "FAKECONTY",
            "product:timeliness": "PT1H30M",
            "processing:version": "1.1.0",
            "processing:datetime": "2022-06-14T13:57:37Z",
            "processing:facility": "ESA S3MPC",
            "processing:software": {"Sentinel-1 IPF": "002.71"},
            "processing:level": "L2",
            "providers": [
                {"name": "S3MPC", "roles": ["processor"]},
                {"name": "ACRI-ST", "roles": ["producer"]},
            ],
        },
        "links": [
            {"rel": "self", "href": "./.zattrs.json", "type": "application/json"},
        ],
        "assets": {},
    }

    return container


@pytest.fixture
def fake_template_product():
    product = init_datatree("test")
    product.product_type = "TEMPLATE_PRODUCT_TYPE"
    # Create groups
    product["measurements"] = DataTree(name="measurements")
    product["measurements/radiance"] = DataTree(name="radiance")
    product["measurements/empty_group"] = DataTree(name="empty_group")

    # --- OA01 ---
    oa01 = xr.DataArray(
        _ones_array((1000, 1000), chunks=(250, 250)) * 2048,
        name="oa01_radiance",
    )
    oa01.attrs.update(
        {
            "long_name": "truc",
            "short_name": "oa01_radiance",
            "dtype": "truc",
        },
    )

    # --- OA02 ---
    oa02 = xr.DataArray(
        _ones_array((1000, 1000), chunks=(250, 250)) * 2048,
        name="oa02_radiance",
    )
    oa02.attrs.update(
        {
            "long_name": "truc",
            "short_name": "oa02_radiance",
            "dtype": "truc",
        },
    )

    # --- Empty group variable ---
    empty = xr.DataArray(
        _ones_array((10, 10), chunks=(10, 10)) * 2048,
        name="empty",
    )
    empty.attrs.update(
        {
            "long_name": "truc",
            "short_name": "truc",
            "dtype": "truc",
        },
    )

    product["measurements/radiance/oa01_radiance"] = oa01
    product["measurements/radiance/oa02_radiance"] = oa02
    product["measurements/empty_group/empty"] = empty
    product.cpm.short_names = {
        "oa01_radiance": "measurements/radiance/oa01_radiance",
        "oa02_radiance": "measurements/radiance/oa02_radiance",
    }
    product.attrs["other_metadata"] = {
        "radiance_coeff": 2.03,
        "absolute_orbit_number": 12,
        "datatake_type": "INS-NOBS",
    }
    product.attrs["stac_discovery"] = {
        "type": "Feature",
        "stac_version": "1.1.0",
        "stac_extensions": [
            "https://cs-si.github.io/eopf-stac-extension/v1.2.0/schema.json",
            "https://stac-extensions.github.io/sat/v1.0.0/schema.json",
            "https://stac-extensions.github.io/product/v0.1.0/schema.json",
            "https://stac-extensions.github.io/processing/v1.2.0/schema.json",
        ],
        "id": "S3A_SL_2_LST____20220614T130003_20220614T130503_20220614T135543_0299_086_238",
        "geometry": {
            "coordinates": [
                [
                    [50.28376, -13.843143],
                    [47.965759, -13.308908],
                    [48.387905, -11.565237],
                    [50.69191, -12.0927],
                    [50.28376, -13.843143],
                ],
            ],
            "type": "Polygon",
        },
        "gsd": "1000",
        "bbox": [50.69191, -13.843143, 47.965759, -11.565237],
        "properties": {
            "collection": "004.06.00",
            "datetime": None,
            "start_datetime": "2022-06-14T13:00:43.45Z",
            "end_datetime": "2022-06-14T13:12:40.45Z",
            "created": "2022-06-14T13:57:37Z",
            "platform": "sentinel-3A",
            "instruments": ["slstr"],
            "constellation": "sentinel-3",
            "mission": "copernicus",
            "sat:anx_datetime": "2022-06-14T12:40:20.457854",
            "sat:absolute_orbit": 32936,
            "sat:relative_orbit": 238,
            "sat:orbit_state": "ascending",
            "sat:platform_international_designator": "2016-011A",
            "eopf:instrument_mode": "INS-NOBS",
            "eopf:datatake_id": "350542",
            "product:type": "TEMPLATE_PRODUCT_TYPE",
            "processing:version": "1.1.0",
            "processing:datetime": "2022-06-14T13:57:37Z",
            "product:timeliness": "PT1H30M",
            "product:timeliness_category": "NRT",
            "processing:facility": "ESA S3MPC",
            "processing:software": {"Sentinel-1 IPF": "002.71"},
            "processing:level": "L2",
            "providers": [
                {"name": "S3MPC", "roles": ["processor"]},
                {"name": "ACRI-ST", "roles": ["producer"]},
            ],
        },
        "links": [
            {"rel": "self", "href": "./.zattrs.json", "type": "application/json"},
        ],
        "assets": {},
    }
    product.attrs["other_metadata"]["integration_time"] = {}
    for b in (
        "b01",
        "b02",
        "b03",
        "b04",
        "b05",
        "b06",
        "b07",
        "b08",
        "B8a",
        "b09",
        "b10",
        "b11",
        "b12",
    ):
        product.attrs["other_metadata"]["integration_time"][b] = 1.30

    product.cpm.product_kind = EOPRODUCT_CATEGORY

    return product
