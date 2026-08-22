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
import copy
from collections.abc import Hashable
from time import sleep
from typing import Any, Optional, Type, cast
from unittest import mock

import numpy as np
import pytest
import xarray as xr
from numpy.fft import fft2
from numpy.typing import DTypeLike
from scipy.ndimage import median_filter
from xarray import DataArray
from xarray.core.datatree import DataTree

from eopf import EOConfiguration
from eopf.common.constants import EOCONTAINER_CATEGORY
from eopf.common.file_utils import AnyPath
from eopf.computing import (
    AuxiliaryDataFile,
    DataType,
    EOProcessingStep,
    EOProcessingUnit,
    MappingAuxiliary,
    MappingDataType,
)
from eopf.computing.breakpoint import eopf_breakpoint_decorator
from eopf.computing.utils import image_generator
from eopf.exceptions.errors import CriticalException, ExceptionWithExitCode
from eopf.product import history_utils
from eopf.product.datatree_validation import ValidationMode


def _dask_array_module():
    return pytest.importorskip("dask.array")


def _dask_image_functions():
    dask_ndfilters = pytest.importorskip("dask_image.ndfilters")
    dask_ndinterp = pytest.importorskip("dask_image.ndinterp")
    dask_ndmorph = pytest.importorskip("dask_image.ndmorph")
    return (
        dask_ndfilters.gaussian_filter,
        dask_ndfilters.sobel,
        dask_ndinterp.rotate,
        dask_ndmorph.binary_opening,
    )


class TestAbstractProcessStep(EOProcessingStep):
    __test__ = False

    def apply(
            self,
            *inputs: np.ndarray[Any, np.dtype[Any]],
            dtype: DTypeLike = float,
            **kwargs: Any,
    ) -> np.ndarray[Any, np.dtype[Any]]: ...


class TestAbstractProcessingUnit(EOProcessingUnit):
    __test__ = False

    def run(
            self,
            inputs: dict[str, DataTree],
            **kwargs: Any,
    ) -> dict[str, DataTree]: ...


def add_variable(tree: DataTree, path: str, data: Any, dims, attrs: dict):
    """
    path is like 'measurements/image/b0'
    """
    varname = path.split("/")[-1]
    ds = xr.Dataset({varname: xr.DataArray(data, dims=dims, attrs=dict(attrs))})
    tree[path] = DataTree(dataset=ds, name=varname)


class TestAbstractProcessor(EOProcessingUnit):
    __test__ = False
    PROCESSOR_NAME = "TestAbstractProcessor"

    @eopf_breakpoint_decorator(identifier="test_abstract_processor")
    def run(
            self,
            inputs: MappingDataType,
            adfs: Optional[dict[str, AuxiliaryDataFile]] = None,
            mode: Optional[str] = None,
            **kwargs: Any,
    ) -> MappingDataType:  # pragma: no cover
        shouldbehere = EOConfiguration()["shouldbehere"]
        if not shouldbehere:
            raise KeyError("Conf shouldbehere is not here")

        image_kwargs = {
            "nb_var": kwargs.get("nb_var", 12),
            "size_x": kwargs.get("size_x", 500),
            "size_y": kwargs.get("size_y", 500),
            "chunk_x": kwargs.get("chunk_x", 125),
            "chunk_y": kwargs.get("chunk_y", 125),
            "min_value": kwargs.get("min_value", 0),
            "max_value": kwargs.get("max_value", 100),
            "deep_level": kwargs.get("deep_level", 0),
        }
        multi_image_kwargs = {
            **image_kwargs,
            "nb_var": kwargs.get("multi_nb_var", kwargs.get("nb_var", 1)),
        }

        return {
            "out": image_generator("", **image_kwargs),
            "multi1": image_generator(
                "multi1",
                **multi_image_kwargs,
                stac_properties={"start_datetime": "2021-01-01T01:01:02"},
            ),
            "multi2": image_generator("multi2", **multi_image_kwargs),
        }

    @classmethod
    def get_mandatory_input_list(
            cls,
            mode: Optional[str] = None,
            **kwargs: Any,
    ) -> list[str]:
        return []


def _compute_threshold_mask(
        block: np.ndarray[Any, np.dtype[Any]],
        threshold: int = 75,
) -> np.ndarray[Any, np.dtype[np.uint8]]:
    return (block > threshold).astype(np.uint8) * 255


def _compute_fft_magnitude(block: np.ndarray[Any, np.dtype[Any]]) -> np.ndarray[Any, np.dtype[Any]]:
    return np.abs(fft2(block))


def _median_denoise(block: np.ndarray[Any, np.dtype[Any]]) -> np.ndarray[Any, np.dtype[Any]]:
    return median_filter(block, size=3)


def _normalize_uint8(block: np.ndarray[Any, np.dtype[Any]]) -> np.ndarray[Any, np.dtype[np.uint8]]:
    mn = block.min()
    mx = block.max()
    if mx == mn:
        return np.zeros_like(block, dtype=np.uint8)
    return ((block - mn) / (mx - mn) * 255).astype(np.uint8)


def _make_image_ds(
        array: Any,
        name: str,
        dims: tuple[Hashable, ...],
        coords: Any,
) -> xr.Dataset:
    da_xr = xr.DataArray(
        array,
        dims=dims,
        coords=coords,
        attrs={
            "long_name": "truc",
            "short_name": name,
            "dtype": "uint16",
        },
    )
    return xr.Dataset({name: da_xr})


def _image_variable_items(image_group: DataTree) -> list[tuple[str, str, xr.DataArray]]:
    """Return image variables from a flat or nested synthetic image group."""
    items: list[tuple[str, str, xr.DataArray]] = []
    for node in image_group.subtree:
        if node.ds is None:
            continue
        for var_name, var_dataarray in node.ds.data_vars.items():
            if not var_name.startswith("b"):
                continue
            relative_group = node.path.removeprefix(image_group.path).strip("/")
            if relative_group == var_name:
                relative_group = ""
            elif relative_group.endswith(f"/{var_name}"):
                relative_group = relative_group.removesuffix(f"/{var_name}")
            items.append((relative_group, var_name, var_dataarray))
    return items


def _nested_output_group(base_group: str, relative_group: str, variable_name: str, suffix: str) -> str:
    """Return the output group path for a flat or nested synthetic variable."""
    if not relative_group:
        return f"{base_group}/{suffix}"
    return f"{base_group}/{relative_group}/{variable_name}/{suffix}"


class TestHeavyProcessingProcessor(EOProcessingUnit):
    __test__ = False

    def run(
            self,
            inputs: MappingDataType,
            adfs: Optional[MappingAuxiliary] = None,
            mode: Optional[str] = None,
            **kwargs: Any,
    ) -> dict[str, DataTree]:  # pragma: no cover
        # ------------------------------------------------------------
        # INPUT HANDLING
        # ------------------------------------------------------------
        inp_tree = cast(DataTree, inputs["in"])  # THIS IS A DataTree
        inp = inp_tree  # alias
        full_image_ops = bool(kwargs.get("full_image_ops", False))

        # Locate input band group
        try:
            band_group = inp["measurements/image"]
        except KeyError:
            raise KeyError("Input does not contain /measurements/image")

        # ------------------------------------------------------------
        # CREATE OUTPUT PRODUCT (empty root)
        # ------------------------------------------------------------
        output = DataTree(name="output")

        # Copy attrs from input (metadata, STAC, etc.)
        output.attrs = dict(inp.attrs)

        # output["measurements"] = DataTree(name="measurements")
        # output["measurements"]["image"] = DataTree(name="image")

        edges_vars: dict[str, xr.DataArray] = {}
        fft_vars: dict[str, xr.DataArray] = {}
        denoised_vars: dict[str, xr.DataArray] = {}
        mask_vars: dict[str, xr.DataArray] = {}
        nested_outputs: dict[str, dict[str, xr.DataArray]] = {}

        for relative_group, var_name, var_dataarray in _image_variable_items(band_group):
            xda = var_dataarray
            coords = xda.coords
            dims = xda.dims

            # Convert to float32 for image operations
            data = xda.data.astype(np.float32)

            if full_image_ops:
                gaussian_filter, sobel, rotate, binary_opening = _dask_image_functions()
                smoothed = gaussian_filter(data, sigma=1)
                mask = smoothed.map_blocks(_compute_threshold_mask, dtype=np.uint8)
                opened_mask = binary_opening(mask, structure=np.ones((3, 3)))
                transformed = rotate(smoothed, angle=30, reshape=False, mode="nearest")
                edges = sobel(transformed).map_blocks(_normalize_uint8, dtype=np.uint8)
                fft_mag = transformed.map_blocks(_compute_fft_magnitude, dtype=np.float32)
                denoised = transformed.map_blocks(_median_denoise, dtype=np.float32)
                denoised = denoised.map_blocks(_normalize_uint8, dtype=np.uint8)
            else:
                opened_mask = (data > 75).astype(np.uint8) * 255
                edges = opened_mask
                fft_mag = data
                denoised = data.astype(np.uint8)

            edges_vars[f"edges_{var_name}"] = xr.DataArray(
                edges,
                dims=dims,
                coords=coords,
                attrs={"long_name": "truc", "short_name": f"edges_{var_name}", "dtype": "uint16"},
            )
            fft_vars[f"fft_{var_name}"] = xr.DataArray(
                fft_mag,
                dims=dims,
                coords=coords,
                attrs={"long_name": "truc", "short_name": f"fft_{var_name}", "dtype": "uint16"},
            )
            denoised_vars[f"denoised_{var_name}"] = xr.DataArray(
                denoised,
                dims=dims,
                coords=coords,
                attrs={"long_name": "truc", "short_name": f"denoised_{var_name}", "dtype": "uint16"},
            )
            mask_vars[f"mask_{var_name}"] = xr.DataArray(
                opened_mask,
                dims=dims,
                coords=coords,
                attrs={"long_name": "truc", "short_name": f"mask_{var_name}", "dtype": "uint16"},
            )

            if relative_group:
                nested_outputs[_nested_output_group("measurements/image", relative_group, var_name, "edges")] = {
                    f"edges_{var_name}": edges_vars.pop(f"edges_{var_name}"),
                }
                nested_outputs[_nested_output_group("measurements/image", relative_group, var_name, "fft")] = {
                    f"fft_{var_name}": fft_vars.pop(f"fft_{var_name}"),
                }
                nested_outputs[_nested_output_group("measurements/image", relative_group, var_name, "denoised")] = {
                    f"denoised_{var_name}": denoised_vars.pop(f"denoised_{var_name}"),
                }
                nested_outputs[_nested_output_group("conditions", relative_group, var_name, "mask")] = {
                    f"mask_{var_name}": mask_vars.pop(f"mask_{var_name}"),
                }

        if nested_outputs:
            for group_path, variables in nested_outputs.items():
                output[group_path] = DataTree(
                    dataset=xr.Dataset(variables),
                    name=group_path.rsplit("/", maxsplit=1)[-1],
                )
        else:
            output["measurements/image/edges"] = DataTree(dataset=xr.Dataset(edges_vars), name="edges")
            output["measurements/image/fft"] = DataTree(dataset=xr.Dataset(fft_vars), name="fft")
            output["measurements/image/denoised"] = DataTree(dataset=xr.Dataset(denoised_vars), name="denoised")
            output["conditions/mask"] = DataTree(dataset=xr.Dataset(mask_vars), name="mask")
            assert output["conditions/mask"] is not None

        # ------------------------------------------------------------
        # RETURN OUTPUT PRODUCT
        # ------------------------------------------------------------
        return {"out": output}

    @classmethod
    def get_mandatory_input_list(
            cls,
            mode: Optional[str] = None,
            **kwargs: Any,
    ) -> list[str]:
        return ["in"]


@pytest.mark.unit
def test_processing_unit_default_configuration_sets_missing_values() -> None:
    if EOConfiguration().has_value("shouldbehere"):
        del EOConfiguration()["shouldbehere"]

    TestAbstractProcessor("test_abstract_processor")

    assert EOConfiguration()["shouldbehere"] == 1


@pytest.mark.unit
def test_processing_unit_default_configuration_does_not_override_user_values() -> None:
    EOConfiguration()["shouldbehere"] = 2

    TestAbstractProcessor("test_abstract_processor")

    assert EOConfiguration()["shouldbehere"] == 2


@pytest.mark.unit
@pytest.mark.dask_only
def test_abstract_heavy_processor(dask_context_threads):
    heavy_in_prod = TestAbstractProcessor("test_abstract_processor").run(
        inputs={},
        size_x=5000,
        size_y=5000,
        chunk_x=2500,
        chunk_y=2500,
        min_value=0,
        max_value=100,
        nb_var=2,
    )

    processing_unit = TestHeavyProcessingProcessor("identifier")
    p = processing_unit.run_validating({"in": heavy_in_prod["out"]})
    assert p is not None
    result = p["out"].compute()
    assert result is not None


@pytest.mark.unit
@pytest.mark.dask_only
def test_heavy_processor_builds_multiband_output_without_compute():
    heavy_in_prod = TestAbstractProcessor("test_abstract_processor").run(
        inputs={},
        size_x=50,
        size_y=50,
        chunk_x=25,
        chunk_y=25,
        nb_var=12,
    )

    result = TestHeavyProcessingProcessor("identifier").run_validating({"in": heavy_in_prod["out"]})

    assert len(result["out"]["measurements/image/edges"].ds.data_vars) == 12
    assert len(result["out"]["measurements/image/fft"].ds.data_vars) == 12
    assert len(result["out"]["measurements/image/denoised"].ds.data_vars) == 12
    assert len(result["out"]["conditions/mask"].ds.data_vars) == 12


@pytest.mark.unit
@pytest.mark.dask_only
def test_heavy_processor_preserves_nested_image_groups_without_compute():
    heavy_in_prod = TestAbstractProcessor("test_abstract_processor").run(
        inputs={},
        size_x=50,
        size_y=50,
        chunk_x=25,
        chunk_y=25,
        nb_var=2,
        deep_level=2,
    )

    result = TestHeavyProcessingProcessor("identifier").run_validating({"in": heavy_in_prod["out"]})

    for path in (
        "measurements/image/level_0/level_1/b0/edges",
        "measurements/image/level_0/level_1/b0/fft",
        "measurements/image/level_0/level_1/b0/denoised",
        "conditions/level_0/level_1/b0/mask",
    ):
        assert result["out"][path] is not None
    assert "edges_b0" in result["out"]["measurements/image/level_0/level_1/b0/edges"].ds.data_vars
    assert "mask_b1" in result["out"]["conditions/level_0/level_1/b1/mask"].ds.data_vars


class TestSleepProcessingProcessor(EOProcessingUnit):
    __test__ = False

    def run(
            self,
            inputs: MappingDataType,
            adfs: Optional[MappingAuxiliary] = None,
            mode: Optional[str] = None,
            **kwargs: Any,
    ) -> MappingDataType:  # pragma: no cover
        logger = logging.getLogger("eopf.testsleeppro")
        logger.info("Start sleep")
        sleep(kwargs.get("time", 120))
        logger.info("End sleep")
        sleep(1)
        return inputs

    @classmethod
    def get_mandatory_input_list(
            cls,
            mode: Optional[str] = None,
            **kwargs: Any,
    ) -> list[str]:
        return ["in"]


@pytest.mark.unit
def test_abstract_sleep_processor(fake_quality_datatree):
    processing_unit = TestSleepProcessingProcessor("identifier")
    print(str(processing_unit))
    print(f"{processing_unit.__class__.__name__}<{processing_unit.identifier}>")
    assert str(processing_unit) == f"{processing_unit.__class__.__name__}<{processing_unit.identifier}>"
    assert (
            repr(processing_unit)
            == f"[{id(processing_unit)}]{processing_unit.__class__.__name__}<{processing_unit.identifier}>"
    )

    assert processing_unit.identifier == "identifier"

    processing_unit.run_validating({"in": fake_quality_datatree}, time=1)


class TestAbstractContainerProcessor(EOProcessingUnit):
    __test__ = False

    @eopf_breakpoint_decorator(identifier="test_abstract_container_processor")
    def run(
            self,
            inputs: dict[str, DataType],
            adfs: Optional[dict[str, AuxiliaryDataFile]] = None,
            mode: Optional[str] = None,
            **kwargs: Any,
    ) -> dict[str, DataTree]:  # pragma: no cover
        # ------------------------------------------------------------
        # CREATE PRODUCT AS A DATATREE
        # ------------------------------------------------------------
        product = DataTree(name="product_name")

        # Attach metadata (STAC, platform, version…)
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
                "processing:version": "1.1.1",
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

        product.attrs["stac_discovery"]["datatake_type"] = "INS-NOBS"

        # ------------------------------------------------------------
        # CREATE MANDATORY GROUPS
        # EOProduct.MANDATORY_FIELD → ("measurements",)
        # ------------------------------------------------------------
        mandatory_groups = ("measurements",)

        for group in mandatory_groups:
            # Create the empty group node
            product[group] = DataTree(name=group)

            # Add /measurements/image/b01
            data = np.random.randint(0, 100, size=(50, 50))
            xda = xr.DataArray(
                data,
                dims=("x", "y"),
                attrs={
                    "long_name": "truc",
                    "short_name": "truc",
                    "dtype": "uint16",
                },
            )

            product[f"{group}/image/b01"] = DataTree(
                dataset=xr.Dataset({"b01": xda}),
                name="b01",
            )

        # ------------------------------------------------------------
        # INSTEAD OF EOContainer.create_from_products(...)
        # WE BUILD A PURE DATATREE CONTAINER:
        #
        #   test (root)
        #     └── product_name  (subtree for product)
        #
        # ------------------------------------------------------------
        container = DataTree(
            name="test",
            children={"product_name": product},
        )
        container.attrs["other_metadata"] = {
            "radiance_coeff": 2.03,
            "absolute_orbit_number": 12,
            "datatake_type": "INS-NOBS",
            "eopf_category": "eoproduct",
        }
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

        # Optionally attach container metadata:
        container.cpm.product_kind = EOCONTAINER_CATEGORY

        return {"out": container}

    @classmethod
    def get_mandatory_input_list(
            cls,
            mode: Optional[str] = None,
            **kwargs: Any,
    ) -> list[str]:
        return []


@pytest.mark.unit
def test_abstract_container_processor(fake_quality_datatree):
    processing_unit = TestAbstractContainerProcessor("identifier")
    print(str(processing_unit))
    print(f"{processing_unit.__class__.__name__}<{processing_unit.identifier}>")
    assert str(processing_unit) == f"{processing_unit.__class__.__name__}<{processing_unit.identifier}>"
    assert (
            repr(processing_unit)
            == f"[{id(processing_unit)}]{processing_unit.__class__.__name__}<{processing_unit.identifier}>"
    )

    assert processing_unit.identifier == "identifier"
    p = processing_unit.run_validating({"in": fake_quality_datatree})
    assert p["out"].cpm.product_kind == EOCONTAINER_CATEGORY


class TestAbstractBlockProcessingStep(EOProcessingStep):
    __test__ = False

    def apply(
            self,
            *inputs: np.ndarray[Any, np.dtype[Any]],
            **kwargs: Any,
    ) -> np.ndarray[Any, np.dtype[Any]]: ...


class TestAbstractOverlapProcessingStep(EOProcessingStep):
    __test__ = False

    def apply(
            self,
            *inputs: np.ndarray[Any, np.dtype[Any]],
            **kwargs: Any,
    ) -> np.ndarray[Any, np.dtype[Any]]: ...


class TestAbstractErrorProcessor(EOProcessingUnit):
    __test__ = False

    def run(
            self,
            inputs: MappingDataType,
            adfs: Optional[MappingAuxiliary] = None,
            mode: Optional[str] = None,
            **kwargs: Any,
    ) -> MappingDataType:  # pragma: no cover
        raise ExceptionWithExitCode("test", exit_code=kwargs.get("exit_code", 30))


@pytest.mark.unit
def test_error_processor():
    with pytest.raises(ExceptionWithExitCode):
        TestAbstractErrorProcessor().run(inputs={})


class TestAbstractCriticalErrorProcessor(EOProcessingUnit):
    __test__ = False

    def run(
            self,
            inputs: MappingDataType,
            adfs: Optional[MappingAuxiliary] = None,
            mode: Optional[str] = None,
            **kwargs: Any,
    ) -> MappingDataType:  # pragma: no cover
        raise CriticalException("test", exit_code=50)


@pytest.mark.unit
def test_critical_error_processor():
    with pytest.raises(CriticalException):
        TestAbstractCriticalErrorProcessor().run(inputs={})


@pytest.fixture
def variable_paths():
    return [
        "measurements/images/oa10_radiance",
        "measurements/images/oa4_radiance",
        "measurements/images/oa1_radiance",
        "measurements/images/oa2_reflectance",
        "condition/missing_value",
        "condition/radiometry/mm",
    ]


@pytest.fixture
def fake_product(variable_paths):
    product = DataTree(name="fake_quality_product")

    for path in variable_paths:
        xda = xr.DataArray(np.array([15]), dims=("dummy",))
        product[path] = DataTree(
            dataset=xr.Dataset({path.split("/")[-1]: xda}),
            name=path.split("/")[-1],
        )

    return product


@pytest.fixture
def output_expected_product(variable_paths):
    product = DataTree(name="expected_product")
    product["/measurements/variable"] = DataArray(
        "variable",
        np.array([15]) * len(variable_paths),
    )
    return product


@pytest.fixture
def valide_output_expected_product(variable_paths):
    product = DataTree(name="expected_product")

    # ----------------------------------------------------
    # Metadata (same structure as original EOProduct)
    # ----------------------------------------------------
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

    # Also the datatake type
    product.attrs["stac_discovery"]["datatake_type"] = "INS-NOBS"

    # ----------------------------------------------------
    # Variable `/measurements/variable`
    # ----------------------------------------------------
    xda = xr.DataArray(
        np.array([15]) * len(variable_paths),
        dims=("dummy",),
        name="variable",
    )

    product["/measurements/variable"] = DataTree(
        dataset=xr.Dataset({"variable": xda}),
        name="variable",
    )

    # ----------------------------------------------------
    # Mandatory group: /measurements/image/b01
    # ----------------------------------------------------
    product["measurements"] = DataTree(name="measurements")
    product["measurements/image"] = DataTree(name="image")

    data = np.random.randint(0, 100, size=(50, 50))
    xda = xr.DataArray(
        data,
        dims=("x", "y"),
        attrs={
            "long_name": "truc",
            "short_name": "truc",
            "dtype": "uint16",
        },
    )

    product["measurements/image/b01"] = DataTree(
        dataset=xr.Dataset({"b01": xda}),
        name="b01",
    )

    return product


@pytest.mark.unit
@pytest.mark.parametrize(
    "arrays, processing_step_type, kwargs, expected_id",
    [
        (
                [np.asarray([1]) for _ in range(10)],
                TestAbstractProcessStep,
                {},
                "identifier",
        ),
        (
                [np.asarray([1]) for _ in range(10)],
                TestAbstractBlockProcessingStep,
                {},
                "identifier",
        ),
        (
                [np.asarray([1]) for _ in range(10)],
                TestAbstractOverlapProcessingStep,
                {},
                "identifier",
        ),
    ],
)
def test_abstract_processing_step(
        arrays: list[np.ndarray],
        processing_step_type: Type[EOProcessingStep],
        kwargs,
        expected_id,
):
    processing_step = processing_step_type("identifier")
    assert processing_step.identifier == expected_id
    with mock.patch(
            f"{processing_step.__class__.__module__}.{processing_step.__class__.__name__}.apply",
    ) as mock_apply:
        processing_step.apply(*arrays, **kwargs)
    mock_apply.assert_called_once_with(*arrays, **kwargs)
    assert all(isinstance(i, np.ndarray) for i in mock_apply.call_args.args)
    assert kwargs == mock_apply.call_args.kwargs


@pytest.mark.unit
@pytest.mark.dask_only
@pytest.mark.parametrize(
    "arrays, processing_step_type, kwargs, expected_id",
    [
        (
                [np.asarray([1]) for _ in range(10)],
                TestAbstractBlockProcessingStep,
                {},
                "identifier",
        ),
        (
                [np.asarray([1]) for _ in range(10)],
                TestAbstractOverlapProcessingStep,
                {},
                "identifier",
        ),
    ],
)
def test_maps_processing_step(
        arrays: list[np.ndarray],
        processing_step_type: Type[EOProcessingStep],
        kwargs,
        expected_id,
):
    da = _dask_array_module()
    dasks_arrays = [da.asarray(array) for array in arrays]
    processing_step = processing_step_type("identifier")
    assert processing_step.identifier == expected_id
    with mock.patch(
            f"{processing_step.__class__.__module__}.{processing_step.__class__.__name__}.apply",
    ) as mock_func:
        mock_func.side_effect = lambda *x: sum(x)
        ret_val = da.map_blocks(
            processing_step.apply,
            *dasks_arrays,
            dtype=float,
            meta=np.array((), dtype=float),
            **kwargs,
        ).compute()
    assert isinstance(ret_val, np.ndarray)
    assert all(isinstance(i, np.ndarray) for i in mock_func.call_args.args)
    assert kwargs == mock_func.call_args.kwargs


@pytest.mark.unit
@pytest.mark.parametrize(
    " kwargs, processing_unit_type, expected_id",
    [
        (
                {
                    "variables_paths": [
                        "measurements/images/oa10_radiance",
                        "measurements/images/oa4_radiance",
                        "measurements/images/oa1_radiance",
                        "measurements/images/oa2_reflectance",
                        "condition/missing_value",
                        "condition/radiometry/mm",
                    ],
                    "dest_path": "/measurements/variable",
                },
                TestAbstractProcessingUnit,
                "identifier",
        ),
    ],
)
def test_abstract_processing_unit(
        fake_quality_datatree,
        kwargs,
        processing_unit_type: Type[EOProcessingUnit],
        expected_id,
):
    processing_unit = processing_unit_type("identifier")
    assert str(processing_unit) == f"{processing_unit.__class__.__name__}<{processing_unit.identifier}>"
    assert (
            repr(processing_unit)
            == f"[{id(processing_unit)}]{processing_unit.__class__.__name__}<{processing_unit.identifier}>"
    )
    assert processing_unit.identifier == expected_id
    with mock.patch(
            f"{processing_unit.__class__.__module__}.{processing_unit.__class__.__name__}.run",
    ) as mock_run:
        processing_unit.run({"in": fake_quality_datatree}, **kwargs)
    mock_run.assert_called_once_with({"in": fake_quality_datatree}, **kwargs)
    assert all(
        (isinstance(p, dict) and all((isinstance(i, DataTree) for i in p.values()))) for p in mock_run.call_args.args
    )
    assert kwargs == mock_run.call_args.kwargs


@pytest.mark.unit
@pytest.mark.parametrize(
    "kwargs, processing_unit_type, expected_id",
    [
        (
                {
                    "variables_paths": [
                        "measurements/images/oa10_radiance",
                        "measurements/images/oa4_radiance",
                        "measurements/images/oa1_radiance",
                        "measurements/images/oa2_reflectance",
                        "condition/missing_value",
                        "condition/radiometry/mm",
                    ],
                    "dest_path": "/measurements/variable",
                },
                TestAbstractProcessor,
                "identifier",
        ),
    ],
)
def test_abstract_processor(
        fake_quality_datatree,
        kwargs,
        processing_unit_type: Type[EOProcessingUnit],
        valide_output_expected_product,
        expected_id,
):
    processing_unit = processing_unit_type("identifier")
    print(str(processing_unit))
    print(f"{processing_unit.__class__.__name__}<{processing_unit.identifier}>")
    assert str(processing_unit) == f"{processing_unit.__class__.__name__}<{processing_unit.identifier}>"
    assert (
            repr(processing_unit)
            == f"[{id(processing_unit)}]{processing_unit.__class__.__name__}<{processing_unit.identifier}>"
    )

    assert processing_unit.identifier == expected_id
    with (
        mock.patch(
            f"{processing_unit.__class__.__module__}.{processing_unit.__class__.__name__}.run",
            return_value={"out": valide_output_expected_product},
        ) as mock_run,
    ):
        processing_unit.run_validating({"in": fake_quality_datatree}, **kwargs)
    mock_run.assert_called_once_with({"in": fake_quality_datatree}, mode="default", **kwargs)
    print(mock_run.call_args.args)
    assert all(
        (isinstance(p, dict) and all((isinstance(i, DataTree) for i in p.values()))) for p in mock_run.call_args.args
    )
    kwargs.update({"mode": "default"})
    assert kwargs == mock_run.call_args.kwargs


@pytest.mark.unit
def test_tasktable_description():
    modes = TestAbstractProcessor.get_available_modes()
    assert len(modes) != 0
    default = TestAbstractProcessor.get_default_mode()
    tasktable = TestAbstractProcessor.get_tasktable_description(default)
    assert len(tasktable) != 0


class TestHistoryProcessor(EOProcessingUnit):
    __test__ = False
    PROCESSOR_NAME = "TestHistoryProcessor"
    PROCESSOR_VERSION = "1.2"
    PROCESSOR_LEVEL = "Level-2 Product"

    def __init__(self, identifier: Any = "") -> None:
        super().__init__(identifier)
        self._update_history = True
        self._additional_history = {"eopf_asgard_version": "2.1.0"}

    def run(
            self,
            inputs: MappingDataType,
            adfs: Optional[MappingAuxiliary] = None,
            mode: Optional[str] = None,
            **kwargs: Any,
    ) -> MappingDataType:  # pragma: no cover
        output: DataTree = copy.deepcopy(cast(DataTree, inputs["in"]))
        output.attrs["stac_discovery"]["properties"]["created"] = "2025-06-14T13:57:37Z"
        output.attrs["stac_discovery"]["id"] = output.cpm.product_id()
        output.cpm.product_type = "L2FAKEY"
        output.name = output.cpm.product_id()
        return {"out": output}


@pytest.mark.unit
@pytest.mark.parametrize(
    "kwargs, processing_unit_type",
    [
        (
                {"band": "b10"},
                TestHistoryProcessor,
        ),
    ],
)
def test_processor_history(
        fake_quality_datatree,
        kwargs,
        processing_unit_type: Type[EOProcessingUnit],
):
    EOConfiguration()["processing_facility"] = "Aperture Science"

    results = processing_unit_type().run_validating(
        inputs={"in": fake_quality_datatree},
        adfs={"dem": AuxiliaryDataFile(name="DEM", path="truc")},
        validation_mode=ValidationMode.NONE,
        **kwargs,
    )

    del EOConfiguration()["processing_facility"]

    assert "processing_history" in cast(DataTree, results["out"]).attrs
    assert processing_unit_type.PROCESSOR_LEVEL in cast(DataTree, results["out"]).attrs["processing_history"]
    history = history_utils.get_history(
        cast(DataTree, results["out"]),
        level_id=-1,
        entry_id=-1,
    )
    assert history is not None
    history_entry = next(iter(history.values()))
    print(history_entry)
    assert history_utils.check_history_entry(history_entry)[0]
    assert history_entry["facility"] == "Aperture Science"
    assert len(history_entry["adfs"]) != 0
    assert "mode" in history_entry["execution_parameters"]
    # Added by the _additional_history
    assert "eopf_asgard_version" in history_entry
    print(history_entry["execution_parameters"])
    assert kwargs.keys() <= history_entry["execution_parameters"].keys()


@pytest.mark.unit
def test_adf_construct_from_str():
    adf = AuxiliaryDataFile(name="ADF", path="truc", adf_params={"machin": "42"})
    assert isinstance(adf.path, str)
    assert isinstance(adf.name, str)
    assert adf.path == "truc"
    assert adf.adf_params == {"machin": "42"}


@pytest.mark.unit
@pytest.mark.real_s3
@pytest.mark.parametrize(
    "raw_url, result",
    [
        ("zip::S3_TEST_DATA_FOLDER/olci_zarr_test.zip", True),
        ("zip::S3_TEST_DATA_FOLDER/olci_zarr_test_not_found.zip", False),
        ("S3_TEST_DATA_FOLDER/olci_zarr_test.zarr", True),
    ],
    ids=["real_file", "fake_file", "real_dir"],
)
def test_adf_file_exists_s3(
        raw_url: str,
        result: bool,
        s3_test_data: tuple[str | None, str],
        s3_config_real: dict[str, object],
) -> None:
    protocol, base_path = s3_test_data
    if protocol is None:
        raise RuntimeError("S3_TEST_DATA_FOLDER must include a protocol")

    url = raw_url.replace("S3_TEST_DATA_FOLDER", f"{protocol}://{base_path}")

    adf = AuxiliaryDataFile(
        name="ADF",
        path=url,
        adf_params={"storage_options": s3_config_real},
    )

    assert AnyPath(adf.path, **adf.adf_params["storage_options"]).exists() is result
