import copy
import os.path
from pathlib import Path
from typing import Any, Optional

import numpy as np
import pytest
import xarray as xr
from xarray import DataTree

from eopf.common.constants import EOCONTAINER_CATEGORY
from eopf.common.file_utils import load_json_file
from eopf.computing import MappingAuxiliary, MappingDataType
from eopf.computing.abstract import EOProcessingUnit
from eopf.computing.types import AuxiliaryDataFile
from eopf.computing.validation import (
    get_mandatory_adf_list,
    get_mandatory_input_list,
    get_model_from_params,
    get_provided_output_list,
    regularize_mode,
    validate_adf_keys,
    validate_adf_models,
    validate_input_keys,
    validate_input_models,
    validate_output_models,
    validate_run_parameters,
)
from eopf.computing.validation_model import (
    AdfRegexSpec,
    AdfSpec,
    DataTypeModel,
    EOProcessingModel,
    ModeConfig,
    ParameterSpec,
)
from eopf.exceptions.errors import EOComputingModelError
from eopf.product.conveniences import init_datatree
from eopf.product.datatree_container_model import EOContainerModel
from eopf.product.datatree_product_model import EOProductModel, EOVariableModel
from eopf.product.datatree_validation import AttributeModel, ValidationMode


@pytest.fixture
def product_spec() -> EOProductModel:
    return EOProductModel(
        variables={"/measurements/radiance/oa01_radiance": EOVariableModel()},
        attrs={"stac_discovery/properties": AttributeModel()},
    )


@pytest.fixture
def output_product_spec() -> EOProductModel:
    return EOProductModel(
        variables={"/measurements/radiance/oa022_radiance": EOVariableModel()},
        attrs={"stac_discovery/properties": AttributeModel()},
    )


@pytest.fixture
def computing_model(product_spec, output_product_spec):
    return EOProcessingModel(
        available_modes=["fast", "accurate"],
        default_mode="fast",
        modes_config={
            "fast": ModeConfig(
                inputs={"in1": DataTypeModel(type="product", spec=product_spec)},
                outputs={"out": DataTypeModel(type="product", spec=output_product_spec)},
                adfs={
                    "machin.*": AdfRegexSpec(
                        spec=AdfSpec(
                            path_pattern=r".*\.json$",
                            required_adf_params=["version"],
                        ),
                    ),
                },
                parameters={
                    "chunk": ParameterSpec(required=True, value_type="int", min_value=1, max_value=1024),
                    "backend": ParameterSpec(required=False, value_type="str", allowed_values=["dask", "numpy"]),
                    "job_name": ParameterSpec(required=False, value_type="str", pattern=r"^[A-Za-z0-9_-]+$"),
                },
            ),
            "accurate": ModeConfig(
                inputs={"in1": DataTypeModel(type="container", spec=EOContainerModel())},
                outputs={},
                adfs={},
                parameters={},
            ),
        },
    )


@pytest.fixture
def iterable_model(product_spec):
    return EOProcessingModel(
        available_modes=["stream"],
        default_mode="stream",
        modes_config={
            "stream": ModeConfig(
                inputs={"in1": DataTypeModel(type="product", spec=product_spec, is_iterable=True)},
                outputs={"out1": DataTypeModel(type="product", spec=product_spec, is_iterable=True)},
                adfs={"machin.*": AdfRegexSpec(spec=AdfSpec())},
                parameters={"chunk": ParameterSpec()},
            ),
        },
    )


@pytest.fixture
def max_occurs_model(product_spec):
    return EOProcessingModel(
        available_modes=["limited"],
        default_mode="limited",
        modes_config={
            "limited": ModeConfig(
                inputs={
                    "in[0-9]": DataTypeModel(
                        type="product",
                        spec=product_spec,
                        min_occurs=1,
                        max_occurs=2,
                    ),
                },
                outputs={
                    "out[0-9]": DataTypeModel(
                        type="product",
                        spec=product_spec,
                        min_occurs=1,
                        max_occurs=2,
                    ),
                },
                adfs={
                    "machin[0-9]": AdfRegexSpec(
                        spec=AdfSpec(),
                        min_occurs=1,
                        max_occurs=2,
                    ),
                },
                parameters={},
            ),
        },
    )


@pytest.fixture
def valid_product():
    product = init_datatree("test")
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
        "properties": {"collection": "004.06.00"},
    }

    product["measurements"] = DataTree(name="measurements")

    arr = np.random.random((1000, 1000)).astype(np.float32) * 2048
    arr = arr.astype(np.float32)

    xda = xr.DataArray(
        arr,
        dims=("x", "y"),
        name="oa01_radiance",
        attrs={"long_name": "truc", "short_name": "truc", "dtype": "truc"},
    )

    product["measurements/radiance"] = DataTree(
        dataset=xr.Dataset({"oa01_radiance": xda}),
        name="oa01_radiance",
    )
    return product


@pytest.fixture
def valid_container(valid_product):
    new_prod = copy.deepcopy(valid_product)
    new_prod.cpm.product_kind = EOCONTAINER_CATEGORY
    new_prod.cpm.product_type = "S011S12131"
    new_prod.name = "testC"
    return new_prod


def _build_single_io_model(*, section: str, key: str, datatype: DataTypeModel) -> EOProcessingModel:
    return EOProcessingModel(
        available_modes=["m"],
        default_mode="m",
        modes_config={"m": ModeConfig(**{section: {key: datatype}})},
    )


@pytest.mark.unit
def test_computing_validation_create(OUTPUT_DIR, computing_model):
    Path(os.path.join(OUTPUT_DIR, "computing")).mkdir(exist_ok=True)
    filepath = Path(os.path.join(OUTPUT_DIR, "computing", "computing.json"))
    with filepath.open("w+") as f:
        f.write(computing_model.model_dump_json(indent=4, exclude_unset=True))
    data = load_json_file(filepath)
    loaded = EOProcessingModel(**data)
    assert loaded


@pytest.mark.unit
def test_computing_validation_validate(computing_model, fake_quality_datatree, valid_adf):
    validate_run_parameters(
        computing_model,
        {"in1": fake_quality_datatree},
        mode="fast",
        adfs={"machin1": valid_adf},
        validate_product_model=True,
        chunk=42,
    )


@pytest.mark.unit
@pytest.mark.parametrize(
    ("available_modes", "default_mode", "modes_config", "match"),
    [
        (
            ["fast"],
            "accurate",
            {"fast": ModeConfig(inputs={"in1": DataTypeModel(type="product", spec=EOProductModel())})},
            "default_mode must be one of available_modes",
        ),
        (
            ["fast"],
            "fast",
            {},
            "modes must include a config for default_mode",
        ),
        (
            ["fast", "accurate"],
            "fast",
            {"fast": ModeConfig(inputs={"in1": DataTypeModel(type="product", spec=EOProductModel())})},
            "modes is missing configs for",
        ),
    ],
)
def test_eoprocessingmodel_validation_errors(available_modes, default_mode, modes_config, match):
    with pytest.raises(EOComputingModelError, match=match):
        EOProcessingModel(
            available_modes=available_modes,
            default_mode=default_mode,
            modes_config=modes_config,
        )


@pytest.mark.unit
def test_invalid_regex_in_mode_config(product_spec):
    with pytest.raises(EOComputingModelError, match="Invalid regex in inputs"):
        ModeConfig(inputs={"[unclosed": DataTypeModel(type="product", spec=product_spec)})


@pytest.mark.unit
def test_data_type_model_unknown_type():
    with pytest.raises(EOComputingModelError, match="Unknown type: unknown"):
        DataTypeModel(type="unknown", spec={})


@pytest.mark.unit
@pytest.mark.parametrize(
    ("mode", "expected"),
    [
        (None, "default"),
        ("custom", "custom"),
    ],
)
def test_regularize_mode_without_model(mode, expected):
    assert regularize_mode(None, mode) == expected


@pytest.mark.unit
def test_regularize_mode_bad_mode(computing_model):
    with pytest.raises(EOComputingModelError, match="Not accepted mode"):
        regularize_mode(computing_model, "wrong_mode")


@pytest.mark.unit
@pytest.mark.parametrize(
    ("func", "kwargs"),
    [
        (
            validate_run_parameters,
            {
                "inputs": lambda dt: {"in1": dt},
                "adfs": {"machin1": "expo"},
                "validate_product_model": True,
                "chunk": "test",
            },
        ),
        (
            validate_output_models,
            {"outputs": lambda dt: {"out": dt}, "validate_product_model": False},
        ),
        (
            validate_input_models,
            {"inputs": lambda dt: {"in1": dt}, "validate_product_model": False},
        ),
        (
            validate_input_keys,
            {"input_keys": ["in1"]},
        ),
        (
            validate_adf_models,
            {"adfs": {"machin1": "ok"}},
        ),
        (
            validate_adf_keys,
            {"adf_keys": ["machin1"]},
        ),
        (
            get_mandatory_input_list,
            {},
        ),
        (
            get_mandatory_adf_list,
            {},
        ),
        (
            get_provided_output_list,
            {},
        ),
    ],
)
def test_public_apis_unknown_mode(computing_model, fake_quality_datatree, func, kwargs):
    resolved_kwargs = {k: v(fake_quality_datatree) if callable(v) else v for k, v in kwargs.items()}
    with pytest.raises(EOComputingModelError, match="Not accepted mode"):
        func(computing_model, mode="unknown", **resolved_kwargs)


@pytest.mark.unit
@pytest.mark.parametrize(
    ("func", "kwargs", "expected"),
    [
        (
            validate_run_parameters,
            {
                "inputs": lambda dt: {"in1": dt},
                "adfs": {
                    "machin1": AuxiliaryDataFile(path="expo.json", name="job_01", adf_params={"version": "01.01"}),
                },
                "validate_product_model": True,
                "chunk": 42,
            },
            [],
        ),
        (
            validate_output_models,
            {"outputs": lambda dt: {"out": dt}, "validate_product_model": False},
            [],
        ),
        (
            validate_input_models,
            {"inputs": lambda dt: {"in1": dt}, "validate_product_model": False},
            [],
        ),
        (
            validate_input_keys,
            {"input_keys": ["in1"]},
            [],
        ),
        (
            validate_adf_models,
            {
                "adfs": {
                    "machin1": AuxiliaryDataFile(path="expo.json", name="job_01", adf_params={"version": "01.01"}),
                },
            },
            [],
        ),
        (
            validate_adf_keys,
            {"adf_keys": ["machin1"]},
            [],
        ),
        (
            get_mandatory_input_list,
            {},
            ["in1"],
        ),
        (
            get_mandatory_adf_list,
            {},
            ["machin.*"],
        ),
        (
            get_provided_output_list,
            {},
            ["out"],
        ),
    ],
)
def test_public_apis_default_mode_when_none(computing_model, fake_quality_datatree, func, kwargs, expected):
    resolved_kwargs = {k: v(fake_quality_datatree) if callable(v) else v for k, v in kwargs.items()}
    result = func(computing_model, **resolved_kwargs)
    assert result == expected


@pytest.mark.unit
@pytest.mark.parametrize(
    ("func", "mode", "expected"),
    [
        (get_mandatory_input_list, "fast", ["in1"]),
        (get_mandatory_adf_list, "fast", ["machin.*"]),
        (get_mandatory_adf_list, "accurate", []),
        (get_provided_output_list, "fast", ["out"]),
        (get_provided_output_list, "accurate", []),
    ],
)
def test_helper_lists(computing_model, func, mode, expected):
    assert func(computing_model, mode=mode) == expected


@pytest.mark.unit
@pytest.mark.parametrize(
    ("func", "arg_name", "values", "mode", "match"),
    [
        (validate_input_keys, "input_keys", ["bad"], "fast", "Unexpected input name 'bad'"),
        (validate_input_keys, "input_keys", [], "fast", "Missing inputs matching pattern 'in1'"),
        (
            validate_input_keys,
            "input_keys",
            ["in1", "in2", "in3"],
            "limited",
            r"Too many inputs matching pattern 'in\[0-9\]'",
        ),
        (validate_adf_keys, "adf_keys", ["machin1", "other"], "fast", "Unexpected adf name 'other'"),
        (validate_adf_keys, "adf_keys", [], "fast", r"Missing adf matching pattern 'machin\.\*'"),
        (
            validate_adf_keys,
            "adf_keys",
            ["machin1", "machin2", "machin3"],
            "limited",
            r"Too many adfs matching pattern 'machin\[0-9\]'",
        ),
    ],
)
def test_key_validators_errors(computing_model, max_occurs_model, func, arg_name, values, mode, match):
    model = max_occurs_model if mode == "limited" else computing_model
    with pytest.raises(EOComputingModelError, match=match):
        func(model, mode=mode, **{arg_name: values})


@pytest.mark.unit
@pytest.mark.parametrize(
    ("func", "arg_name", "values"),
    [
        (validate_input_keys, "input_keys", ["in1"]),
        (validate_adf_keys, "adf_keys", ["machin1"]),
    ],
)
def test_key_validators_ok(computing_model, func, arg_name, values):
    func(computing_model, mode="fast", **{arg_name: values})


@pytest.fixture
def valid_adf(tmp_path) -> AuxiliaryDataFile:
    adf_file = tmp_path / "machin.json"
    adf_file.write_text("{}")
    return AuxiliaryDataFile(
        name="machin1",
        path=str(adf_file),
        adf_params={"version": "1.0"},
    )


@pytest.mark.unit
@pytest.mark.parametrize(
    ("adfs", "match"),
    [
        (
            {
                "machin1": AuxiliaryDataFile(name="machin1", path="/tmp/test.json"),
                "other": AuxiliaryDataFile(name="other", path="/tmp/other.json"),
            },
            "Unexpected adf name 'other'",
        ),
        (
            {},
            r"Missing adf matching pattern 'machin\.\*'",
        ),
        (
            {"machin1": "not_an_adf"},
            r"ADF 'machin1' must be an AuxiliaryDataFile",
        ),
        (
            {"machin1": AuxiliaryDataFile(name="machin1", path="")},
            r"ADF 'machin1' must define a non-empty path",
        ),
        (
            {"machin1": AuxiliaryDataFile(name="machin1", path="/tmp/test.txt")},
            r"path '/tmp/test.txt' does not match required pattern",
        ),
        (
            {"machin1": AuxiliaryDataFile(name="machin1", path="/tmp/test.json", adf_params={})},
            r"missing required adf_params entry 'version'",
        ),
    ],
)
def test_validate_adf_models_errors(computing_model, adfs, match):
    with pytest.raises(EOComputingModelError, match=match):
        validate_adf_models(computing_model, adfs, mode="fast")


@pytest.mark.unit
def test_validate_adf_models_ok(computing_model, valid_adf):
    validate_adf_models(computing_model, {"machin1": valid_adf}, mode="fast")


@pytest.mark.unit
@pytest.mark.parametrize(
    ("func", "payload", "mode", "match"),
    [
        (
            validate_run_parameters,
            lambda dt: {
                "inputs": {"in3": dt},
                "mode": "fast",
                "adfs": {"machin1": "expo"},
                "validate_product_model": True,
                "chunk": "test",
            },
            "fast",
            "Unexpected input name 'in3'",
        ),
        (
            validate_run_parameters,
            lambda dt: {
                "inputs": {"in1": dt},
                "mode": "fast",
                "adfs": {"machin1": "expo", "other": "expo"},
                "validate_product_model": True,
                "chunk": "test",
            },
            "fast",
            "Unexpected adf name 'other'",
        ),
        (
            validate_run_parameters,
            lambda dt: {
                "inputs": {"in1": dt},
                "mode": "fast",
                "adfs": {},
                "validate_product_model": True,
                "chunk": "test",
            },
            "fast",
            r"Missing adf matching pattern 'machin\.\*'",
        ),
        (
            validate_run_parameters,
            lambda dt: {
                "inputs": {"in1": dt},
                "mode": "fast",
                "adfs": {"machin1": "expo"},
                "validate_product_model": True,
            },
            "fast",
            "Missing required parameter 'chunk'",
        ),
        (
            validate_run_parameters,
            lambda dt: {
                "inputs": {"in1": dt},
                "mode": "fast",
                "adfs": {"machin1": "expo"},
                "validate_product_model": True,
                "chunk": "test",
                "unknown_kw": 1,
            },
            "fast",
            "Unexpected parameter 'unknown_kw'",
        ),
        (
            validate_run_parameters,
            lambda dt: {
                "inputs": {"in1": dt, "in2": dt, "in3": dt},
                "mode": "limited",
            },
            "limited",
            r"Too many inputs matching pattern 'in\[0-9\]'",
        ),
        (
            validate_run_parameters,
            lambda dt: {
                "inputs": {"in1": dt},
                "mode": "limited",
                "adfs": {"machin1": "a", "machin2": "b", "machin3": "c"},
            },
            "limited",
            r"Too many adfs matching pattern 'machin\[0-9\]'",
        ),
    ],
)
def test_validate_run_parameters_errors(
    computing_model, max_occurs_model, fake_quality_datatree, func, payload, mode, match,
):
    model = max_occurs_model if mode == "limited" else computing_model
    with pytest.raises(EOComputingModelError, match=match):
        func(model, **payload(fake_quality_datatree))


@pytest.mark.unit
@pytest.mark.parametrize(
    ("func", "kwargs", "expected_category", "expected_message"),
    [
        (
            validate_input_models,
            {
                "inputs": {"in1": 12},
                "mode": "fast",
                "validate_product_model": False,
                "raises": False,
            },
            "INPUT",
            "must be a single DataTree",
        ),
        (
            validate_output_models,
            {
                "outputs": {"out": 42},
                "mode": "fast",
                "validate_product_model": False,
                "raises": False,
            },
            "OUTPUT",
            "must be a single DataTree",
        ),
        (
            validate_input_keys,
            {
                "input_keys": ["bad"],
                "mode": "fast",
                "raises": False,
            },
            "INPUT",
            "Unexpected input name 'bad'",
        ),
        (
            validate_adf_keys,
            {
                "adf_keys": ["other"],
                "mode": "fast",
                "raises": False,
            },
            "ADF",
            "Unexpected adf name 'other'",
        ),
        (
            validate_adf_models,
            {
                "adfs": {},
                "mode": "fast",
                "raises": False,
            },
            "ADF",
            "Missing adf matching pattern 'machin.*'",
        ),
    ],
)
def test_validation_apis_no_raise_return_anomalies(computing_model, func, kwargs, expected_category, expected_message):
    anomalies = func(computing_model, **kwargs)

    assert anomalies
    assert any(a.category == expected_category for a in anomalies)
    assert any(expected_message in a.description for a in anomalies)


@pytest.mark.unit
@pytest.mark.parametrize(
    ("func", "model_fixture", "payload", "mode", "match"),
    [
        (
            validate_input_models,
            "computing_model",
            lambda dt: {"in1": 12},
            "fast",
            "must be a single DataTree",
        ),
        (
            validate_input_models,
            "computing_model",
            lambda dt: {"in1": [dt]},
            "fast",
            "can't be iterable",
        ),
        (
            validate_input_models,
            "iterable_model",
            lambda dt: {"in1": dt},
            "stream",
            "must be iterable",
        ),
        (
            validate_output_models,
            "computing_model",
            lambda dt: {"badout": dt},
            "fast",
            "Unexpected output name 'badout'",
        ),
        (
            validate_output_models,
            "computing_model",
            lambda dt: {},
            "fast",
            "Missing outputs matching pattern 'out'",
        ),
        (
            validate_output_models,
            "computing_model",
            lambda dt: {"out": 42},
            "fast",
            "Output 'out' must be a single DataTree",
        ),
        (
            validate_output_models,
            "computing_model",
            lambda dt: {"out": [dt]},
            "fast",
            "can't be iterable",
        ),
        (
            validate_output_models,
            "iterable_model",
            lambda dt: {"out1": dt},
            "stream",
            "must be iterable",
        ),
        (
            validate_output_models,
            "max_occurs_model",
            lambda dt: {"out1": dt, "out2": dt, "out3": dt},
            "limited",
            r"Too many outputs matching pattern 'out\[0-9\]'",
        ),
    ],
)
def test_input_output_model_errors(request, fake_quality_datatree, func, model_fixture, payload, mode, match):
    model = request.getfixturevalue(model_fixture)
    with pytest.raises(EOComputingModelError, match=match):
        func(model, payload(fake_quality_datatree), mode=mode, validate_product_model=False)


@pytest.mark.unit
@pytest.mark.parametrize(
    ("func", "key"),
    [
        (validate_input_models, "in1"),
        (validate_output_models, "out1"),
    ],
)
def test_iterable_generator_is_opaque(iterable_model, fake_quality_datatree, func, key):
    def gen():
        for _ in range(3):
            yield fake_quality_datatree

    stream = gen()
    func(iterable_model, {key: stream}, mode="stream", validate_product_model=True)
    assert len(list(stream)) == 3


@pytest.mark.unit
@pytest.mark.parametrize(
    ("section", "key", "validator"),
    [
        ("inputs", "in1", validate_input_models),
        ("outputs", "out", validate_output_models),
    ],
)
def test_container_with_product_model_fails(product_spec, valid_container, section, key, validator):
    model = _build_single_io_model(
        section=section,
        key=key,
        datatype=DataTypeModel(type="product", spec=product_spec),
    )
    with pytest.raises(
        EOComputingModelError,
        match=rf"Product model found while the data is a container for product : {key}",
    ):
        validator(model, {key: valid_container}, mode="m", validate_product_model=True)


@pytest.mark.unit
@pytest.mark.parametrize(
    ("section", "key", "validator"),
    [
        ("inputs", "in1", validate_input_models),
        ("outputs", "out", validate_output_models),
    ],
)
def test_container_model_ok(valid_container, section, key, validator):
    model = _build_single_io_model(
        section=section,
        key=key,
        datatype=DataTypeModel(type="container", spec=EOContainerModel()),
    )
    validator(model, {key: valid_container}, mode="m", validate_product_model=True)


@pytest.mark.unit
@pytest.mark.parametrize(
    ("section", "key", "validator"),
    [
        ("inputs", "in1", validate_input_models),
        ("outputs", "out", validate_output_models),
    ],
)
def test_unknown_product_kind_fails(valid_product, section, key, validator):
    bad_product = copy.deepcopy(valid_product)
    bad_product.cpm.product_kind = "UNKNOWN_KIND"
    model = _build_single_io_model(
        section=section,
        key=key,
        datatype=DataTypeModel(type="product", spec=EOProductModel()),
    )
    with pytest.raises(EOComputingModelError, match=rf"Unknown product kind for product : {key}"):
        validator(model, {key: bad_product}, mode="m", validate_product_model=True)


@pytest.mark.unit
@pytest.mark.parametrize(
    ("section", "key", "validator"),
    [
        ("inputs", "in1", validate_input_models),
        ("outputs", "out", validate_output_models),
    ],
)
def test_invalid_product_anomaly(valid_product, section, key, validator):
    model = _build_single_io_model(
        section=section,
        key=key,
        datatype=DataTypeModel(
            type="product",
            spec=EOProductModel(variables={"/missing/path": EOVariableModel()}),
        ),
    )
    with pytest.raises(EOComputingModelError, match=rf"Invalid Product {key}:"):
        validator(model, {key: valid_product}, mode="m", validate_product_model=True)


@pytest.mark.unit
@pytest.mark.parametrize(
    "value_factory",
    [
        lambda p: p,
        lambda p: [p],
    ],
)
def test_get_model_from_params_unknown_product_kind_fails(valid_product, value_factory):
    bad_product = copy.deepcopy(valid_product)
    bad_product.cpm.product_kind = "UNKNOWN_KIND"

    with pytest.raises(EOComputingModelError, match="Only .* allowed"):
        get_model_from_params(
            inputs={"in1": value_factory(bad_product)},
            mode="definitus",
        )


@pytest.mark.unit
def test_model_from_param(valid_product, valid_container, OUTPUT_DIR, tmp_path):
    adf_file = tmp_path / "machin_S2B.json"
    adf_file.write_text("{}")

    computing_model = get_model_from_params(
        inputs={"in1": [valid_product for _ in range(5)], "in2": valid_container},
        adfs={
            "machin_S2B": AuxiliaryDataFile(
                name="machin_S2B",
                path=str(adf_file),
                adf_params={"version": "1.0"},
            ),
        },
        mode="definitus",
        chunk=124,
        validation_mode=ValidationMode.STRUCTURE,
    )

    assert computing_model.default_mode == "definitus"

    in1 = computing_model.modes_config["definitus"].inputs["in1"]
    assert in1.type == "product"
    assert in1.is_iterable is True

    in2 = computing_model.modes_config["definitus"].inputs["in2"]
    assert in2.type == "container"
    assert in2.is_iterable is False

    adf_spec = computing_model.modes_config["definitus"].adfs["machin_S2B"].spec
    assert adf_spec.path_pattern is not None
    assert "json" in adf_spec.path_pattern
    assert adf_spec.required_adf_params == ["version"]

    params = computing_model.modes_config["definitus"].parameters
    assert params["chunk"].value_type == "int"

    Path(os.path.join(OUTPUT_DIR, "computing")).mkdir(exist_ok=True)
    filepath = Path(os.path.join(OUTPUT_DIR, "computing", "computing_from_param.json"))
    with filepath.open("w+") as f:
        f.write(computing_model.model_dump_json(indent=4, exclude_unset=True))


@pytest.mark.unit
def test_model_from_param_empty_iterable_fails(valid_container, tmp_path):
    adf_file = tmp_path / "machin_S2B.json"
    adf_file.write_text("{}")

    with pytest.raises(EOComputingModelError, match="Cannot infer model from empty iterable input 'in1'"):
        get_model_from_params(
            inputs={"in1": [], "in2": valid_container},
            adfs={
                "machin_S2B": AuxiliaryDataFile(
                    name="machin_S2B",
                    path=str(adf_file),
                    adf_params={"version": "1.0"},
                ),
            },
            mode="definitus",
            chunk=124,
            validation_mode=ValidationMode.STRUCTURE,
        )


@pytest.mark.unit
def test_get_model_from_params_iterable_container(valid_container):
    computing_model = get_model_from_params(
        inputs={"in1": [valid_container for _ in range(3)]},
        mode="definitus",
    )

    in1 = computing_model.modes_config["definitus"].inputs["in1"]
    assert in1.type == "container"
    assert in1.is_iterable is True


@pytest.mark.unit
def test_get_model_from_params_infers_parameter_types(valid_product):
    computing_model = get_model_from_params(
        inputs={"in1": valid_product},
        mode="definitus",
        int_param=1,
        float_param=1.5,
        str_param="abc",
        bool_param=True,
        validation_mode=ValidationMode.STRUCTURE,
    )

    params = computing_model.modes_config["definitus"].parameters
    assert params["int_param"].value_type == "int"
    assert params["float_param"].value_type == "float"
    assert params["str_param"].value_type == "str"
    assert params["bool_param"].value_type == "bool"


@pytest.mark.unit
def test_get_model_from_params_infers_adf_spec(tmp_path, valid_product):
    adf_file = tmp_path / "calibration.json"
    adf_file.write_text("{}")

    computing_model = get_model_from_params(
        inputs={"in1": valid_product},
        adfs={
            "calibration": AuxiliaryDataFile(
                name="calibration",
                path=str(adf_file),
                adf_params={"version": "1.0", "mission": "S3A"},
            ),
        },
        mode="definitus",
    )

    adf_spec = computing_model.modes_config["definitus"].adfs["calibration"].spec
    assert adf_spec.path_pattern is not None
    assert "json" in adf_spec.path_pattern
    assert adf_spec.required_adf_params == ["mission", "version"]


####################################
# ProcessingUnit validation part
####################################


class ValidationProcessor(EOProcessingUnit):
    PROCESSOR_NAME = "ComputingValidation"
    PROCESSOR_VERSION = "1.0.0"

    def run(
        self,
        inputs: MappingDataType,
        adfs: Optional[MappingAuxiliary] = None,
        mode: Optional[str] = None,
        **kwargs: Any,
    ) -> MappingDataType:
        values = list(inputs["in1"])
        return {"out986": values[0]}


@pytest.mark.unit
@pytest.mark.parametrize(
    "in1",
    [
        pytest.param(lambda p: [p for _ in range(5)], id="list"),
        pytest.param(lambda p: (p for _ in range(5)), id="generator"),
    ],
)
def test_computing_validation_processor(valid_product, valid_container, in1):
    proc = ValidationProcessor()
    output = proc.run_validating(
        inputs={"in1": in1(valid_product), "in2": valid_container},
        adfs={"machin1": AuxiliaryDataFile(path="expo.json", name="job_01", adf_params={"version": "01.01"})},
        mode="definitus",
        chunk=124,
        validation_mode=ValidationMode.STRUCTURE,
    )
    assert output is not None


@pytest.mark.unit
def test_computing_validation_processor_failed_bad_container(valid_product):
    proc = ValidationProcessor()
    with pytest.raises(EOComputingModelError):
        proc.run_validating(
            inputs={"in1": (valid_product for _ in range(5)), "in2": valid_product},
            adfs={"machin1": AuxiliaryDataFile(path="expo.json", name="job_01", adf_params={"version": "01.01"})},
            mode="definitus",
            chunk=124,
            validation_mode=ValidationMode.STRUCTURE,
        )


@pytest.mark.unit
@pytest.mark.parametrize(
    ("kwargs", "match"),
    [
        (
            {},
            "Missing required parameter 'chunk'",
        ),
        (
            {"chunk": 1, "unknown_kw": 1},
            "Unexpected parameter 'unknown_kw'",
        ),
        (
            {"chunk": "test"},
            r"Parameter 'chunk' must be of type int, got str",
        ),
        (
            {"chunk": 0},
            r"Parameter 'chunk' must be >= 1",
        ),
        (
            {"chunk": 2048},
            r"Parameter 'chunk' must be <= 1024",
        ),
        (
            {"chunk": 1, "backend": "spark"},
            r"Parameter 'backend' must be one of",
        ),
        (
            {"chunk": 1, "job_name": "bad name with spaces"},
            r"Parameter 'job_name' value 'bad name with spaces' does not match pattern",
        ),
        (
            {"chunk": 1, "job_name": 12},
            r"Parameter 'job_name' must be of type str, got int",
        ),
    ],
)
def test_validate_run_parameters_kwargs_errors(computing_model, fake_quality_datatree, kwargs, match):
    with pytest.raises(EOComputingModelError, match=match):
        validate_run_parameters(
            computing_model,
            {"in1": fake_quality_datatree},
            mode="fast",
            adfs={"machin1": AuxiliaryDataFile(path="expo.json", name="job_01", adf_params={"version": "01.01"})},
            validate_product_model=True,
            **kwargs,
        )


@pytest.mark.unit
@pytest.mark.parametrize(
    "kwargs",
    [
        {"chunk": 1},
        {"chunk": 128, "backend": "dask"},
        {"chunk": 128, "backend": "numpy", "job_name": "job_01"},
    ],
)
def test_validate_run_parameters_kwargs_ok(computing_model, fake_quality_datatree, kwargs):
    validate_run_parameters(
        computing_model,
        {"in1": fake_quality_datatree},
        mode="fast",
        adfs={"machin1": AuxiliaryDataFile(path="expo.json", name="job_01", adf_params={"version": "01.01"})},
        validate_product_model=True,
        **kwargs,
    )
