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
import datetime
import logging
import re
import traceback
from contextlib import nullcontext
from typing import Optional
from unittest import mock

import pytest
import yaml
from click.testing import CliRunner
from fastapi.testclient import TestClient

from eopf import open_datatree
from eopf.cli.cli_triggering_triggers import trigger_cli
from eopf.cli.services.kafka_server import kafka_consumer_cli
from eopf.cli.services.web_server import create_web_app, web_services_cli
from eopf.common.file_utils import AnyPath
from eopf.exceptions import TriggeringConfigurationError
from eopf.exceptions.errors import TriggerInvalidWorkflow
from eopf.product.conveniences import init_datatree
from eopf.store.reader_registry import EOReaderRegistry
from eopf.triggering.general_utils import resolve_storage_options
from eopf.triggering.runner import EORunner


@pytest.mark.need_files
@pytest.mark.unit
@pytest.mark.dask_only
@pytest.mark.parametrize(
    "args, match_output",
    [(["local"], r"Server return status code [0-9]{3} with content: .*")],
)
def test_cli_trigger(TRIGGER_YAML_FILE_FILLED, args, match_output):
    data = run_cli_trigger(TRIGGER_YAML_FILE_FILLED, args)
    output_breakpoing = AnyPath.cast(data["breakpoints"]["folder"])
    assert output_breakpoing.exists()
    breakpoints_folder = output_breakpoing.ls()
    assert len(breakpoints_folder) != 0
    for brpf in breakpoints_folder:
        prod_brkp = brpf.ls()
        assert len(prod_brkp) != 0
        for pf in prod_brkp:
            print(pf.get_url_and_params())
            loaded_prod = open_datatree(filename_or_obj=pf.get_url_and_params()[0])
            assert "measurements" in loaded_prod


@pytest.mark.need_files
@pytest.mark.unit
@pytest.mark.dask_only
@pytest.mark.parametrize(
    "args, match_output",
    [(["local"], r"Server return status code [0-9]{3} with content: .*")],
)
def test_cli_trigger_relative(TRIGGER_YAML_RELATIVE_FILLED, args, match_output):
    data = run_cli_trigger(
        TRIGGER_YAML_RELATIVE_FILLED[0],
        args,
        TRIGGER_YAML_RELATIVE_FILLED[1],
    )
    output_breakpoing = AnyPath.cast(data["breakpoints"]["folder"]).make_absolute(
        AnyPath.cast(TRIGGER_YAML_RELATIVE_FILLED[1]),
    )
    assert output_breakpoing.exists()
    breakpoints_folder = output_breakpoing.ls()
    assert len(breakpoints_folder) != 0
    for brpf in breakpoints_folder:
        prod_brkp = brpf.ls()
        assert len(prod_brkp) != 0
        for pf in prod_brkp:
            loaded_prod = open_datatree(filename_or_obj=pf.get_url_and_params()[0])
            assert "measurements" in loaded_prod


@pytest.mark.need_files
@pytest.mark.unit
@pytest.mark.dask_only
@pytest.mark.parametrize(
    "args, match_output",
    [(["local"], r"Server return status code [0-9]{3} with content: .*")],
)
def test_cli_datatree_trigger(TRIGGER_YAML_DATATREE_FILE_FILLED, args, match_output):
    data = run_cli_trigger(TRIGGER_YAML_DATATREE_FILE_FILLED, args)

    output_breakpoing = AnyPath.cast(data["breakpoints"]["folder"])
    assert output_breakpoing.exists()
    breakpoints_folder = output_breakpoing.ls()
    assert len(breakpoints_folder) != 0
    for brpf in breakpoints_folder:
        prod_brkp = brpf.ls()
        assert len(prod_brkp) != 0
        for pf in prod_brkp:
            loaded_prod = open_datatree(filename_or_obj=pf.get_url_and_params()[0])
            assert "measurements" in loaded_prod


def run_cli_trigger(yaml_file, args, used_output_dir: Optional[str] = None):
    runner = CliRunner()
    with mock.patch(
            "tests.ut.computing.test_abstract.TestAbstractProcessor.get_mandatory_input_list",
    ) as mmand:
        mmand.return_value = ["in1"]
        r = runner.invoke(trigger_cli, args=" ".join([*args, yaml_file]))

    if r.exception is not None:
        traceback.print_exception(
            type(r.exception),
            r.exception,
            r.exception.__traceback__,
        )
    # assert re.match(match_output, r.output) is not None, r.output
    assert r.exception is None
    assert r.exit_code == 0
    # We then try to open the output product and breakpoint
    with open(yaml_file) as f:
        data = yaml.safe_load(f)
    output_product = AnyPath.cast(data["io"]["output_products"][0]["path"])
    print(output_product)
    if used_output_dir is not None:
        output_product = AnyPath.cast(
            data["io"]["output_products"][0]["path"],
        ).make_absolute(
            AnyPath.cast(used_output_dir),
        )
        print(output_product)
        print(AnyPath.cast(used_output_dir))
    assert output_product.exists()
    loaded_prod = open_datatree(filename_or_obj=output_product.fs_path)
    assert "measurements" in loaded_prod
    output_product.rm(recursive=True)
    if used_output_dir is not None:
        outputs_product = AnyPath.cast(
            data["io"]["output_products"][1]["path"],
        ).make_absolute(
            AnyPath.cast(used_output_dir),
        )
    else:
        outputs_product = AnyPath.cast(data["io"]["output_products"][1]["path"])
    assert outputs_product.exists()
    print(outputs_product.glob("*zarr"))
    assert len(outputs_product.glob("*zarr")) == 2
    outputs_product.rm(recursive=True)
    return data


@pytest.mark.need_files
@pytest.mark.unit
@pytest.mark.dask_only
@pytest.mark.parametrize(
    "args, match_output",
    [
        (
            ["local"],
            r"1",
        ),
    ],
)
def test_cli_trigger_exception_missing_input(
    TRIGGER_YAML_FILE_FILLED,
    args,
    match_output,
):
    runner = CliRunner()
    with mock.patch(
            "tests.ut.computing.test_abstract.TestAbstractProcessor.get_mandatory_input_list",
    ) as mmand:
        mmand.return_value = ["in1", "in2"]
        r = runner.invoke(
            trigger_cli,
            args=" ".join([*args, TRIGGER_YAML_FILE_FILLED]),
        )

    if r.exception is not None:
        traceback.print_exception(
            type(r.exception),
            r.exception,
            r.exception.__traceback__,
        )
    print(match_output)
    print(r.exception)
    assert re.match(match_output, str(r.exception)) is not None
    assert r.exception is not None
    assert r.exit_code != 0


@pytest.mark.need_files
@pytest.mark.unit
@pytest.mark.dask_only
def test_cli_trigger_exit_code(TRIGGER_YAML_ERROR_FILE_FILLED):
    cli_test_exit_code(TRIGGER_YAML_ERROR_FILE_FILLED, ["local"], 30)


def cli_test_exit_code(TRIGGER_YAML_ERROR_FILE_FILLED, args, exit_code):
    runner = CliRunner()
    r = runner.invoke(
        trigger_cli,
        args=" ".join([*args, TRIGGER_YAML_ERROR_FILE_FILLED]),
    )
    if r.exception is not None:
        traceback.print_exception(
            type(r.exception),
            r.exception,
            r.exception.__traceback__,
        )
    print(r.exception)
    assert r.exception is not None
    assert r.exit_code == exit_code


@pytest.mark.need_files
@pytest.mark.unit
@pytest.mark.dask_only
def test_cli_trigger_best_exit_code(TRIGGER_YAML_ERROR_BEST_EFFORT_FILE_FILLED):
    cli_test_exit_code(TRIGGER_YAML_ERROR_BEST_EFFORT_FILE_FILLED, ["local"], 1796)


@pytest.mark.need_files
@pytest.mark.unit
@pytest.mark.dask_only
def test_cli_trigger_critical_exit_code(TRIGGER_YAML_ERROR_CRITICAL_FILE_FILLED):
    cli_test_exit_code(TRIGGER_YAML_ERROR_CRITICAL_FILE_FILLED, ["local"], 50)


@pytest.mark.real_s3
@pytest.mark.unit
@pytest.mark.dask_only
@pytest.mark.parametrize(
    "args, match_output",
    [(["local"], r"Server return status code [0-9]{3} with content: .*")],
)
def test_cli_s3_trigger(TRIGGER_YAML_S3_FILE_FILLED, args, match_output):
    runner = CliRunner()
    with mock.patch(
            "tests.ut.computing.test_abstract.TestAbstractProcessor.get_mandatory_input_list",
        return_value=["in1"],
    ):
        r = runner.invoke(
            trigger_cli,
            args=" ".join([*args, TRIGGER_YAML_S3_FILE_FILLED]),
        )

    print(r.output)
    print(r.stdout)
    print(r.exception)
    # assert re.match(match_output, r.output) is not None, r.output
    if r.exception is not None:
        traceback.print_exception(
            type(r.exception),
            r.exception,
            r.exception.__traceback__,
        )
    assert r.exception is None
    assert r.exit_code == 0
    # We then try to open the output product and breakpoint
    with open(TRIGGER_YAML_S3_FILE_FILLED) as f:
        data = yaml.safe_load(f)

    storage_options = resolve_storage_options(data["io"]["output_products"][0]["writer_params"])["storage_options"]
    output_product = AnyPath.cast(
        data["io"]["output_products"][0]["path"],
        **storage_options,
    )
    assert output_product.exists()
    loaded_prod = open_datatree(
        filename_or_obj=output_product.get_url_and_params()[0], **(output_product.get_url_and_params()[1]),
    )
    assert "measurements" in loaded_prod
    assert "quality" in loaded_prod
    assert loaded_prod["quality"].attrs["qc"]["global_status"] == "PASSED"
    output_product.rm(recursive=True)
    output_breakpoing = AnyPath.cast(data["breakpoints"]["folder"])
    assert output_breakpoing.exists()
    breakpoints_folder = output_breakpoing.ls()
    assert len(breakpoints_folder) != 0
    for brpf in breakpoints_folder:
        prod_brkp = brpf.ls()
        assert len(prod_brkp) != 0
        for pf in prod_brkp:
            print(pf.get_url_and_params())
            loaded_prod = open_datatree(filename_or_obj=pf.get_url_and_params()[0], **(pf.get_url_and_params()[1]))
            assert "measurements" in loaded_prod


@pytest.mark.need_files
@pytest.mark.unit
@pytest.mark.dask_only
@pytest.mark.parametrize(
    "args, match_output",
    [(["local"], r"Server return status code [0-9]{3} with content: .*")],
)
def test_cli_trigger_container(TRIGGER_YAML_CONTAINER_FILE_FILLED, args, match_output):
    runner = CliRunner()
    with mock.patch(
            "tests.ut.computing.test_abstract.TestAbstractContainerProcessor.get_mandatory_input_list",
        return_value=["in1"],
    ):
        r = runner.invoke(
            trigger_cli,
            args=" ".join([*args, TRIGGER_YAML_CONTAINER_FILE_FILLED]),
        )

    print(r.output)
    print(r.stdout)
    print(r.exception)
    if r.exception is not None:
        traceback.print_exception(
            type(r.exception),
            r.exception,
            r.exception.__traceback__,
        )
    # assert re.match(match_output, r.output) is not None, r.output
    assert r.exception is None
    assert r.exit_code == 0
    # We then try to open the output product and breakpoint
    with open(TRIGGER_YAML_CONTAINER_FILE_FILLED) as f:
        data = yaml.safe_load(f)
    output_product = AnyPath.cast(data["io"]["output_products"][0]["path"])
    assert output_product.exists()
    loaded_prod = open_datatree(filename_or_obj=output_product.fs_path)
    assert len(loaded_prod) > 0
    output_breakpoing = AnyPath.cast(data["breakpoints"]["folder"])
    assert output_breakpoing.exists()
    breakpoints_folder = output_breakpoing.ls()
    assert len(breakpoints_folder) != 0
    for brpf in breakpoints_folder:
        prod_brkp = brpf.ls()
        assert len(prod_brkp) != 0
        for pf in prod_brkp:
            loaded_prod = open_datatree(filename_or_obj=pf.get_url_and_params()[0])
            assert "measurements" in loaded_prod["product_name"]


@pytest.fixture
def fake_kafka_consumer(TRIGGER_YAML_FILE_FILLED):
    """This mock Kafka consumer returns a record with the json file as payload."""

    with open(TRIGGER_YAML_FILE_FILLED) as f:
        data = yaml.safe_load(f)

    class FakeKafkaConsumer:
        def __init__(self, length=1):
            self.length = length
            self._called = 0

        def __aiter__(self):
            if self._called >= self.length:
                raise StopAsyncIteration
            return self

        def get_value(self):
            return data

        async def __anext__(self):
            if self._called >= self.length:
                raise StopAsyncIteration
            from aiokafka.structs import ConsumerRecord

            self._called += 1
            return ConsumerRecord(
                "run",
                partition=0,
                offset=0,
                timestamp=datetime.datetime.now().timestamp(),
                timestamp_type=0,
                key="a",
                value=yaml.safe_dump(self.get_value()),
                checksum=1,
                serialized_key_size=1,
                serialized_value_size=1,
                headers=[],
            )

    return FakeKafkaConsumer(1)


@pytest.mark.need_files
@pytest.mark.unit
@pytest.mark.dask_only
def test_kafka_send(TRIGGER_YAML_FILE_FILLED):
    """This test mocks Kafka to test the Kafka triggers sending a message.

    This way the code can be tested without actually needing a running Kafka instance.
    """

    runner = CliRunner()
    with (
        mock.patch("aiokafka.AIOKafkaProducer.start") as start,
        mock.patch("aiokafka.AIOKafkaProducer.send_and_wait") as send,
        mock.patch("aiokafka.AIOKafkaProducer.stop") as stop,
        mock.patch(
            "tests.ut.computing.test_abstract.TestAbstractProcessor.run",
            return_value={"out": init_datatree("")},
        ),
    ):
        runner.invoke(
            trigger_cli,
            args=f"kafka {TRIGGER_YAML_FILE_FILLED}",
        )
    assert start.call_count == 1
    assert send.call_count == 1
    assert stop.call_count == 1


@pytest.mark.need_files
@pytest.mark.unit
@pytest.mark.dask_only
def test_kafka_consume(fake_kafka_consumer):
    """This test mocks Kafka to test the Kafka triggers consuming a message.

    This way the code can be tested without actually needing a running Kafka instance.
    """

    runner = CliRunner()
    with (
        mock.patch("aiokafka.AIOKafkaConsumer.start") as start,
        mock.patch(
            "aiokafka.AIOKafkaConsumer.__aiter__",
            return_value=fake_kafka_consumer,
        ) as retrieve,
        mock.patch("aiokafka.AIOKafkaConsumer.stop") as stop,
        mock.patch("aiokafka.AIOKafkaConsumer._closed", return_value=True),
        mock.patch(
            "tests.ut.computing.test_abstract.TestAbstractProcessor.run",
            return_value={"out": init_datatree("")},
        ),
    ):
        r = runner.invoke(kafka_consumer_cli, args=())
        assert r.exception is None
        assert r.exit_code == 0

    assert start.call_count == 1
    assert retrieve.call_count == 1
    assert stop.call_count == 1


@pytest.fixture
def client():
    return TestClient(create_web_app())


@pytest.mark.need_files
@pytest.mark.unit
@pytest.mark.dask_only
def test_web_trigger(client, TRIGGER_YAML_FILE_FILLED):
    with open(TRIGGER_YAML_FILE_FILLED, encoding="utf-8") as f:
        data = yaml.safe_load(f)

    r = client.post("/run", json=data)
    print(r.json())
    assert r.status_code == 200
    assert r.json() == {}

    r = client.post("/run", json={})
    # empty payload 400
    assert r.status_code == 400
    assert "err" in r.json()


@pytest.mark.unit
def test_web_services_cli(monkeypatch):
    called = {}

    def fake_run(app, host, port, log_level):
        called["app"] = app
        called["host"] = host
        called["port"] = port
        called["log_level"] = log_level

    monkeypatch.setattr("eopf.cli.services.web_server.uvicorn.run", fake_run)

    runner = CliRunner()
    result = runner.invoke(
        web_services_cli,
        ["--host", "0.0.0.0", "--port", "9999", "--log-level", "debug"],
    )

    assert result.exit_code == 0
    assert called["host"] == "0.0.0.0"
    assert called["port"] == 9999
    assert called["log_level"] == "debug"


@pytest.mark.need_files
@pytest.mark.unit
@pytest.mark.parametrize("trigger_class", [EORunner])
@pytest.mark.parametrize(
    "payload",
    [
        {
            "workflow": [
                {
                    "module": "tests.ut.computing.test_dummy",
                    "processing_unit": "TestDummyProcessor",
                    "parameters": {"key": "value"},
                    "name": "unit_1",
                },
            ],
            "io": {
                "input_products": [
                    {
                        "id": "OLCI",
                        "path": "product_path.SAFE",
                        "engine": "safe",
                        "store_params": {},
                    },
                ],
                "output_products": [
                    {
                        "id": "output",
                        "path": "output.zarr",
                        "engine": "cpm_zarr",
                        "store_params": {},
                    },
                ],
            },
        },
        {
            "workflow": [
                {
                    "module": "tests.ut.computing.test_dummy",
                    "processing_unit": "TestDummyProcessor",
                    "parameters": {"key": "value"},
                    "name": "unit_1",
                },
            ],
            "io": {
                "input_products": [
                    {
                        "id": "OLCI",
                        "path": ".product_path.SAFE",
                        "engine": "safe",
                        "store_params": {},
                    },
                ],
                "output_products": [
                    {
                        "id": "output",
                        "path": "output.zarr",
                        "engine": "cpm_zarr",
                        "store_params": {},
                    },
                ],
            },
            "logging": ["$EOPF_ROOT/logging/conf/default.json"],
        },
        {
            "workflow": [
                {
                    "module": "tests.ut.computing.test_dummy",
                    "processing_unit": "TestDummyProcessor",
                    "parameters": {"key": "value"},
                    "name": "unit_1",
                    "inputs": {"in1": "OLCI"},
                },
                {
                    "module": "tests.ut.computing.test_dummy",
                    "processing_unit": "TestDummyProcessor",
                    "parameters": {"key": "value"},
                    "inputs": {"in1": "unit_1"},
                    "name": "unit_2",
                },
            ],
            "io": {
                "input_products": [
                    {
                        "id": "OLCI",
                        "path": ".product_path.SAFE",
                        "engine": "safe",
                        "store_params": {},
                    },
                ],
                "output_products": [
                    {"id": "output", "path": "output.zarr", "engine": "cpm_zarr"},
                ],
            },
        },
    ],
)
def test_extract_payload(trigger_class, payload, monkeypatch):
    monkeypatch.setenv("EOPF_ROOT", "eopf")
    parsers_results = trigger_class().extract_from_payload_and_init_conf_logging(
        payload,
    )
    if isinstance(payload["workflow"], list):
        units_classes, parameters = zip(
            *[(unit["processing_unit"], unit.get("parameters", {})) for unit in payload["workflow"]],
        )
        assert all(
            (unit.processing_unit.__class__.__name__ in units_classes and unit.parameters in parameters)
            for unit in parsers_results.processing_workflow.plan.workflow
        )
    else:
        assert parsers_results.processing_workflow.plan.workflow[0].processing_unit.__class__.__name__ == payload[
            "workflow"
        ].get(
            "processing_unit",
        )
        assert parsers_results.processing_workflow.plan.workflow[0].parameters == payload["workflow"].get(
            "parameters",
            {},
        )
    inputs_products_data = payload["io"].get("input_products")
    inputs_products = parsers_results.io_config.input_products
    for input_product_data in inputs_products_data:
        product = inputs_products[input_product_data["id"]]
        engine = product.engine
        assert EOReaderRegistry.contains(engine)
        assert (
            AnyPath.cast(product.path).make_absolute() == AnyPath.cast(input_product_data.get("path")).make_absolute()
        )
        assert product.reader_params == resolve_storage_options(
            input_product_data.get("store_params", {}),
        )

    output_product_data = payload["io"].get("output_products")

    print(parsers_results.io_config.output_products)

    print(output_product_data[0].get("engine"))
    print(EOReaderRegistry.available())
    assert EOReaderRegistry.contains(output_product_data[0].get("engine"))

    assert parsers_results.io_config.output_products[output_product_data[0]["id"]].writer_params == resolve_storage_options(
        payload["io"]
        .get("output_products", {})[0]
        .get(
            "store_params",
            {},
        ),
    )

    assert parsers_results.context_managers == []


@pytest.mark.unit
@pytest.mark.parametrize("trigger_class", [EORunner])
@pytest.mark.parametrize(
    "payload, exception, cause",
    [
        (
            {
                "workflow": [
                    {
                        "module": "tests.ut.computing.test_dummy",
                        "processing_unit": "",
                        "name": "truc",
                    },
                ],
                "io": {
                    "input_products": [
                        {
                            "id": "OLCI",
                            "path": ".product_path.SAFE",
                            "engine": "safe",
                        },
                    ],
                    "output_products": [
                        {"id": "output", "path": "output.zarr", "engine": "cpm_zarr"},
                    ],
                },
            },
            TriggeringConfigurationError,
            ".*Class  not found in module tests.ut.computing.test_dummy.*",
        ),
        (
            {
                "workflow": [
                    {
                        "module": "",
                        "processing_unit": "TestDummyProcessor",
                        "name": "truc",
                    },
                ],
                "io": {
                    "input_products": [
                        {
                            "id": "OLCI",
                            "path": ".product_path.SAFE",
                            "engine": "safe",
                        },
                    ],
                    "output_products": [
                        {"id": "output", "path": "output.zarr", "engine": "cpm_zarr"},
                    ],
                },
            },
            TriggeringConfigurationError,
            "Error while importing module  : <class 'ValueError'> Empty module name",
        ),
        (
            {
                "workflow": [
                    {
                        "module": "aaaa",
                        "processing_unit": "TestDummyProcessor",
                        "name": "truc",
                    },
                ],
                "io": {
                    "input_products": [
                        {
                            "id": "OLCI",
                            "path": ".product_path.SAFE",
                            "engine": "safe",
                        },
                    ],
                    "output_products": [
                        {"id": "output", "path": "output.zarr", "engine": "cpm_zarr"},
                    ],
                },
            },
            TriggeringConfigurationError,
            ".*Error while importing module aaaa.*",
        ),
        (
            {
                "workflow": [
                    {
                        "module": "tests.ut.computing.test_dummy",
                        "processing_unit": "TestDummyProcessor",
                        "parameters": {"key": "value"},
                    },
                ],
                "io": {
                    "modification_mode": "invalide_mode",
                    "input_products": [
                        {
                            "id": "OLCI",
                            "path": ".product_path.SAFE",
                            "engine": "safe",
                        },
                    ],
                    "output_products": [
                        {"id": "output", "path": "output.zarr", "engine": "cpm_zarr"},
                    ],
                },
            },
            TriggeringConfigurationError,
            ".*missing value for field .*",
        ),
        pytest.param(
            {
                "workflow": [
                    {
                        "name": "truc",
                        "module": "tests.ut.computing.test_abstract",
                        "processing_unit": "TestAbstractProcessor",
                        "parameters": {"key": "value"},
                    },
                ],
                "io": {
                    "input_products": [
                        {
                            "id": "OLCI",
                            "path": ".product_path.SAFE",
                            "engine": "safe",
                        },
                    ],
                    "output_products": [
                        {"id": "output", "path": "output.zarr", "engine": "cpm_zarr"},
                    ],
                },
            },
            TriggerInvalidWorkflow,
            ".*Missing input for unit tests.ut.computing.test_abstract.TestAbstractProcesso.*",
            marks=pytest.mark.dask_only,
        ),
    ],
)
def test_failed_extract_payload(trigger_class, payload, exception, cause):
    patch_context = nullcontext()
    if any(unit.get("module") == "tests.ut.computing.test_abstract" for unit in payload["workflow"]):
        patch_context = mock.patch(
            "tests.ut.computing.test_abstract.TestAbstractProcessor.get_mandatory_input_list",
            return_value=["in1"],
        )

    with patch_context:
        with pytest.raises(exception) as r:
            trigger_class().extract_from_payload_and_init_conf_logging(payload)

        assert re.match(cause, str(r.value)) is not None


@pytest.mark.unit
@pytest.mark.parametrize(
    "log_conf",
    [
        {
            "version": 1,
            "loggers": {
                "eopf": {
                    "level": "DEBUG",
                    "handlers": ["console"],
                },
            },
            "handlers": {
                "console": {
                    "class": "logging.StreamHandler",
                    "formatter": "default",
                },
            },
            "formatters": {
                "default": {
                    "format": (
                        "%(asctime)s : %(levelname)s : %(module)s : %(funcName)s : %(lineno)d : "
                        "(Process Details : (%(process)d, %(processName)s), "
                        "Thread Details : (%(thread)d, %(threadName)s))\nLog : %(message)s"
                    ),
                },
            },
        },
        {
            "eopf": "info",
            "distributed.admin.log-format": (
                "%(asctime)s : %(levelname)s : %(module)s : %(funcName)s : %(lineno)d : "
                "(Process Details : (%(process)d, %(processName)s), "
                "Thread Details : (%(thread)d, %(threadName)s))\nLog : %(message)s"
            ),
        },
    ],
)
@pytest.mark.dask_only
def test_configuration_logging(log_conf):
    from eopf.dask_utils.dask_logging import configure_dask_logging

    configure_dask_logging("local", log_conf)
    if "version" in log_conf:
        for logger_name, logger_config in log_conf.get("loggers", {}).items():
            tested_logger = logging.getLogger(logger_name)
            if "level" in logger_config:
                assert logging.getLevelName(tested_logger.level) == logger_config["level"].upper()
                assert all(handler.name in logger_config["handlers"] for handler in tested_logger.handlers)
    else:
        for logger_name, level in log_conf.items():
            tested_logger = logging.getLogger(logger_name)
            assert logging.getLevelName(tested_logger.level) == level.upper()
