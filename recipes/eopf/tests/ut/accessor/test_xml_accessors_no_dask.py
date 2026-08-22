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
from typing import Optional

import numpy
import pytest
from xarray import DataArray


from eopf.accessor import (
    EOAccessor,
    XMLAnglesAccessor,
    XMLManifestAccessor,
    XMLMultipleFilesAccessor,
    XMLTPAccessor,
)
from eopf.accessor.conveniences import open_accessor
from eopf.accessor.xml_accessors import (
    AbstractXMLCommonOpenAccessor,
    XMLAngleNamesAccessorS02,
    XMLAnglesAccessorS02,
    XMLIncidenceAnglesAccessorS02,
    XMLMeanIncidenceAnglesAccessorS02,
    XMLMeanSunAnglesAccessorS02,
    XMLSingleFileAccessor,
)
from eopf.common import env_utils
from eopf.exceptions.errors import (
    AccessorNotOpenError,
    MissingArgumentError,
    XmlParsingError,
)

_FILES = {
    "netcdf": "test_ncdf_file_.nc",
    "netcdf0": "test_ncdf_read_file_.nc",
    "netcdf1": "test_ncdf_write_file_.nc",
    "json": "test_metadata_file_.json",
    "zarr": "test_zarr_files_.zarr",
    "zarr0": "test_zarr_read_files_.zarr",
    "zarr1": "test_zarr_write_files_.zarr",
    "cog": "test_cog.cog",
}

"""
xml angles accesor tests
"""


@pytest.fixture
def mapping(request) -> str:
    return request.getfixturevalue(request.param)


@pytest.mark.unit
@pytest.mark.parametrize("mapping", ["S02MSIL1C_MAPPING"], indirect=["mapping"])
@pytest.mark.parametrize(
    "expected_data, mapping_dict",
    [
        (
            "truc",
            {
                "stac_discovery": {
                    "type": "Text(Feature)",
                    "id": "n1:General_Info/Product_Info/PRODUCT_URI",
                    "geometry": "to_geoJson(metadataSection/metadataObject[@ID='measurementFrameSet']/"
                    "metadataWrap/xmlData/safe:frameSet/safe:footPrint/gml:coordinates)",
                    "bbox": "to_bbox(metadataSection/metadataObject[@ID='measurementFrameSet']/"
                    "metadataWrap/xmlData/safe:frameSet/safe:footPrint/gml:coordinates)",
                    "adfs": "to_s02_adfs(['PRODUCTION_DEM_TYPE', 'GRI_List/GRI_FILENAME',"
                    "  'IERS_BULLETIN_FILENAME', 'ECMWF_DATA_REF', 'GIPP_List/GIPP_FILENAME'])",
                    "properties": {
                        "datetime": "to_datetime(n1:General_Info/Product_Info/*[contains(local-name(), '_TIME')])",
                        "sat:relative_orbit": "to_int(n1:General_Info/Product_Info/Datatake/SENSING_ORBIT_NUMBER)",
                    },
                    "proj:shape": [
                        "to_imageSize(Syn_Oa01_reflectance.nc:dim_0)",
                        "to_imageSize(Syn_Oa01_reflectance.nc:dim_1)",
                    ],
                },
            },
        ),
    ],
)
def test_xml_manifest(
    mapping,
    expected_data,
    mapping_dict,
        EMBEDED_TEST_DATA_FOLDER_UNIT,
):
    # Create and open xml angles accessor
    with open(mapping) as mapping_file:
        map_config = json.load(mapping_file)
    config = {
        "namespaces": map_config["xml_mapping"]["namespace"],
        "mapping": mapping_dict,
    }
    xml_accessor = XMLManifestAccessor(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "accessor", "xml", "S2B_MSIL1C_MTD_TL.xml"), **config)
    with open_accessor(xml_accessor, **config):
        data = xml_accessor.get_data("")
        assert data is not None
        assert data.attrs


@pytest.mark.unit
@pytest.mark.parametrize("mapping", ["S02MSIL1C_MAPPING"], indirect=["mapping"])
def test_sub_xml_angle(EMBEDED_TEST_DATA_FOLDER_UNIT, mapping):
    with open(mapping) as mapping_file:
        json.load(mapping_file)
    accessor = XMLAnglesAccessor(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "common", "MTD_TL.xml"))

    with pytest.raises(NotImplementedError):
        accessor.open(mode="wrong_mode")
        assert True

    with pytest.raises(TypeError):
        local_config = {}
        # Openening accessor with no configuration, should raise keyerror
        with open_accessor(accessor, **local_config):
            assert True

    with pytest.raises(NotImplementedError):
        accessor.write_data("key", "value")
        assert True

    with pytest.raises(NotImplementedError):
        accessor.write_attrs(None, None)
        assert True


"""
xml tiepoints tests
"""


@pytest.mark.unit
@pytest.mark.parametrize("mapping", ["S02MSIL1C_MAPPING"], indirect=["mapping"])
@pytest.mark.parametrize("array_size", [(23,)])
@pytest.mark.parametrize("ul, dummy_array_factor, kind, reversed", [(300000, 1, "x", "y"), (4800000, -1, "y", "x")])
def test_xml_tiepoints_accessor(
    EMBEDED_TEST_DATA_FOLDER_UNIT, mapping, ul, dummy_array_factor, kind, reversed,
    array_size,
):
    xpath = 'n1:Geometric_Info/Tile_Geocoding/Geoposition[@resolution="10"]/UL{}'
    # Compute a user defined tie points array with values similar with ones from XML.
    COL_STEP = 5000

    # Create XMLAccessors configuration
    with open(mapping) as mapping_file:
        map_config = json.load(mapping_file)

    config = {
        "namespace": map_config["xml_mapping"]["namespace"],
        "step_path": map_config["xml_mapping"]["xmltp_angles"][f"step_{kind}_angle"],
        "values_path": map_config["xml_mapping"]["xmltp_angles"]["angle_values"],
    }
    tp_accessor = XMLTPAccessor(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "common", "MTD_TL.xml"))
    dummy_array = [ul + (dummy_array_factor * idx) * COL_STEP for idx in range(array_size[0])]

    # Create XMLAccessors
    tp_accessor = XMLTPAccessor(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "common", "MTD_TL.xml"))
    with pytest.raises(MissingArgumentError):
        tp_accessor.open()
    # No effects
    tp_accessor.open(mode="w")

    # Normal call
    with open_accessor(tp_accessor, **config):
        assert tp_accessor.get_data(xpath.format(kind.upper())).shape == array_size
        print(f"xpath {xpath.format(kind.upper())}")
        assert numpy.array_equal(dummy_array, tp_accessor.get_data(xpath.format(kind.upper())))

        # Verify incorrect path
        with pytest.raises(KeyError):
            tp_accessor.get_data("random_incorect_xpath")

        with pytest.raises(NotImplementedError):
            tp_accessor.write_attrs("", {})


"""
xml manifest tests
"""


@pytest.mark.unit
@pytest.mark.parametrize(
    "mapping",
    ["S03OLCEFR_MAPPING"], indirect=["mapping"],
)
def test_extended_xml_manifest_accessor(EMBEDED_TEST_DATA_FOLDER_UNIT, mapping):
    manifest_filename = os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "formatting", "S3_*_1_xfdumanifest.xml")
    manifest_accessor = XMLManifestAccessor(manifest_filename)
    with open(mapping) as mapping_file:
        map_olci = json.load(mapping_file)
    config = {"namespaces": map_olci["namespaces"], "mapping": map_olci["stac_discovery"]}
    with open_accessor(manifest_accessor, **config):
        eog = manifest_accessor.get_data("")
        assert isinstance(eog, DataArray)
        stac_discovery = eog.attrs
        expected_type = "Feature"
        expected_instrument = ["olci"]
        expected_links = [{"rel": "collection", "href": "./.zattrs.json", "type": "application/json"}]
        assert stac_discovery["type"] == expected_type
        assert stac_discovery["properties"]["instruments"] == expected_instrument
        # assert isinstance(stac_discovery["properties"]["eopf:resolutions"]["FR"], int)
        # assert stac_discovery["properties"]["eopf:resolutions"]["FR"] == expected_FR_res
        # assert isinstance(
        #    stac_discovery["properties"]["eopf:product"]["pixel_classification"]["bright"]["percent"],
        #    float,
        # )
        # assert (
        #    stac_discovery["properties"]["eopf:product"]["pixel_classification"]["bright"]["percent"]
        #    == expected_bright_percent
        # )
        assert stac_discovery["links"] == expected_links
    config = {"namespaces": map_olci["namespaces"], "mapping": map_olci["other_metadata"]}
    manifest_accessor = XMLManifestAccessor(manifest_filename)
    with open_accessor(manifest_accessor, **config):
        eog = manifest_accessor.get_data("")
        assert isinstance(eog, DataArray)
        conditions_metadata = eog.attrs
        expected_ephemeris = {
            "start": {
                "TAI": "2020-01-01T09:33:53.825486",
                "UTC": "2020-01-01T09:33:16.825486Z",
                "UT1": "2020-01-01T09:33:16.648568",
                "position": {"x": -7134399.613, "y": -838641.089, "z": -0.004},
                "velocity": {"x": -183.334412, "y": 1631.071145, "z": 7366.537065},
            },
            "stop": {
                "TAI": "2020-01-01T11:14:52.990229",
                "UTC": "2020-01-01T11:14:15.990229Z",
                "UT1": "2020-01-01T11:14:15.813289",
                "position": {"x": -6810629.029, "y": 2284455.415, "z": -0.001},
                "velocity": {"x": 529.833647, "y": 1553.517139, "z": 7366.523391},
            },
        }
        print(expected_ephemeris)
        print(conditions_metadata["ephemeris"])
        assert conditions_metadata["ephemeris"] == expected_ephemeris
        assert conditions_metadata
        from datetime import datetime

        assert datetime.strptime(
            conditions_metadata["ephemeris"]["start"]["TAI"],
            "%Y-%m-%dT%H:%M:%S.%f",
        )

    with pytest.raises(NotImplementedError):
        manifest_accessor.open(mode="wrong_mode")


@pytest.mark.unit
def test_manifest_accessor_must_be_open():
    """Given a manifest store, when accessing items inside it without previously opening it,
    the function must raise a AccessorNotOpenError error.
    """
    store = XMLManifestAccessor(_FILES["json"])
    with pytest.raises(AccessorNotOpenError):
        store.get_data("a_group")


@pytest.mark.unit
def test_init_manifest_store():
    """Given a manifest store, with an XML file path as URL,
    the manifest's url must match the one given.
    """
    url = "/root/tmp"
    manifest: EOAccessor = XMLManifestAccessor(url)
    assert manifest.url == url


@pytest.mark.unit
@pytest.mark.parametrize(
    "config, exception_type",
    [
        ({"mapping": {}}, MissingArgumentError),
        ({"namespaces": {}}, MissingArgumentError),
        ({"namespaces": {}, "mapping": {}}, FileNotFoundError),
    ],
)
def test_open_manifest_store(config: Optional[dict], exception_type: Exception):
    """Given a manifest store, without passing configuration parameters
    the function must raise a MissingConfigurationParameter error.
    """
    store: EOAccessor = XMLManifestAccessor(_FILES["json"])
    with pytest.raises(exception_type):
        store.open(**config)


@pytest.mark.unit
def test_close_manifest_store():
    """Given a manifest store, when trying to close it while not previously opening it,
    the function must raise a AccessorNotOpenError error.
    """
    store: EOAccessor = XMLManifestAccessor(_FILES["json"])
    with pytest.raises(AccessorNotOpenError):
        store.close()


@pytest.mark.unit
def test_write_manifest(EMBEDED_TEST_DATA_FOLDER_UNIT, OUTPUT_DIR):
    output_file = os.path.join(OUTPUT_DIR, "tmp_manifest.xml")
    manifest = XMLManifestAccessor(output_file)
    with env_utils.env_context_eopf():
        with open_accessor(
            manifest,
            mode="w",
            path_template={
                "template_folder": os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "accessor", "xml"),
                "template_name": "xml_manifest_template.xml",
            },
        ):
            manifest.write_data(
                "",
                DataArray(
                    name="test",
                    attrs={
                        "properties": {
                            "start_datetime": "20210405T235959",
                            "end_datetime": "20210406T235959",
                        },
                    },
                ),
            )
            pass
    assert os.path.exists(output_file)


@pytest.mark.unit
def test_to_str_lower_list(EMBEDED_TEST_DATA_FOLDER_UNIT):
    manifest_filename = os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "accessor", "xml", "to_lower_test.xml")
    manifest_accessor = XMLManifestAccessor(manifest_filename)
    config = {
        "namespaces": {},
        "mapping": {"truc": "data", "machin": "to_str_lower(data)", "much": "to_str_lower(plop)"},
    }
    with open_accessor(manifest_accessor, **config):
        eog = manifest_accessor.get_data("")
        assert eog.attrs["truc"] == ["A", "B"]
        assert eog.attrs["machin"] == ["a", "b"]
        assert eog.attrs["much"] == "c"


"""
xml multiple files tests
"""


@pytest.mark.unit
def test_xml_multi_files_error_cases(EMBEDED_TEST_DATA_FOLDER_UNIT):
    with pytest.raises(FileNotFoundError):
        accessor = XMLMultipleFilesAccessor("")
    with pytest.raises(NotImplementedError):
        accessor = XMLMultipleFilesAccessor(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "xmlmultifiles", "s1*.xml"))
        accessor.open(mode="w")
    with pytest.raises(TypeError):
        accessor = XMLMultipleFilesAccessor(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "xmlmultifiles", "s1*.xml"))
        accessor.open(mode="r")


@pytest.mark.unit
@pytest.mark.parametrize(
    "xpath, target_type",
    [
        ("dopplerCentroid/dcEstimateList/dcEstimate#dataDcPolynomial", {"name": "float32", "default_value": "NaN"}),
        (
            "dopplerCentroid/dcEstimateList/dcEstimate#dataDcRmsErrorAboveThreshold",
            {"name": "bool", "default_value": False},
        ),
    ],
)
def test_xml_single_file(xpath, target_type, EMBEDED_TEST_DATA_FOLDER_UNIT):
    accessor = XMLSingleFileAccessor(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "xmlmultifiles", "s1*001.xml"))
    with open_accessor(accessor, mode="r", target_type=target_type):
        data = accessor.get_data(xpath)
        assert data is not None


@pytest.mark.unit
@pytest.mark.parametrize("mapping", ["S02MSIL1C_MAPPING"], indirect=["mapping"])
@pytest.mark.parametrize(
    "xpath, accessor_type, shape, expected",
    [
        (
            "n1:Geometric_Info/Tile_Angles/Mean_Viewing_Incidence_Angle_List",
            XMLMeanIncidenceAnglesAccessorS02,
            (13, 2),
            "7.77617758568857",
        ),
        (
            "n1:Geometric_Info/Tile_Angles/Mean_Sun_Angle",
            XMLMeanSunAnglesAccessorS02,
            (2,),
            "30.5600517112155",
        ),
        (
            "n1:Geometric_Info/Tile_Angles/Mean_Sun_Angle",
            XMLAngleNamesAccessorS02,
            (2,),
            "zenith",
        ),
        (
            "n1:Geometric_Info/Tile_Angles/Sun_Angles_Grid",
            XMLAnglesAccessorS02,
            (2, 23, 23),
            "31.2484",
        ),
        (
            "n1:Geometric_Info/Tile_Angles/Viewing_Incidence_Angles_Grids",
            XMLIncidenceAnglesAccessorS02,
            (13, 5, 2, 23, 23),
            "NaN",
        ),
    ],
)
def test_xml_angles_s02(mapping, xpath, accessor_type, shape, expected, EMBEDED_TEST_DATA_FOLDER_UNIT):
    accessor = accessor_type(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "accessor", "xml", "S2B_MSIL1C_MTD_TL.xml"))

    # Create XMLAccessors configuration
    with open(mapping) as mapping_file:
        map_config = json.load(mapping_file)

    config = {
        "namespace": map_config["xml_mapping"]["namespace"],
    }

    with open_accessor(
        accessor,
        mode="r",
        **config,
    ):
        data = accessor.get_data(xpath)
        assert data is not None
        assert data.shape == shape
        print(repr(data))
        print(data.data)
        assert data.values.flat[0] == expected


@pytest.mark.unit
def test_common_open_accessor_exceptions_with_existing_file(EMBEDED_TEST_DATA_FOLDER_UNIT):
    """Covers AbstractXMLCommonOpenAccessor.open error paths using a real test xml."""

    class DummyAccessor(AbstractXMLCommonOpenAccessor):
        def get_data(self, key):
            raise NotImplementedError

    good_xml = f"{EMBEDED_TEST_DATA_FOLDER_UNIT}/common/MTD_TL.xml"
    # missing namespace
    with pytest.raises(TypeError):
        DummyAccessor(good_xml).open()
    # wrong file path
    with pytest.raises(FileNotFoundError):
        DummyAccessor(good_xml + "_missing").open(namespace={})
    # broken xml content (copy the file then corrupt it)
    bad_xml = f"{EMBEDED_TEST_DATA_FOLDER_UNIT}/accessor/xml/bad.xml"
    with open(bad_xml, "w") as f:
        f.write("<bad")
    with pytest.raises(XmlParsingError):
        DummyAccessor(bad_xml).open(namespace={})


@pytest.mark.unit
def test_xmltp_accessor_error_branches(EMBEDED_TEST_DATA_FOLDER_UNIT, S02MSIL1C_MAPPING):
    """Reuse MTD_TL.xml to exercise XMLTPAccessor error branches."""
    with open(S02MSIL1C_MAPPING) as f:
        map_conf = __import__("json").load(f)
    tp = XMLTPAccessor(f"{EMBEDED_TEST_DATA_FOLDER_UNIT}/common/MTD_TL.xml")
    # missing mandatory arguments
    with pytest.raises(MissingArgumentError):
        tp.open()
    # proper open, but wrong dimension in _get_tie_points_data
    tp.open(
        mode="r",
        namespace=map_conf["xml_mapping"]["namespace"],
        step_path=map_conf["xml_mapping"]["xmltp_angles"]["step_x_angle"],
        values_path=map_conf["xml_mapping"]["xmltp_angles"]["angle_values"],
    )

    with pytest.raises(KeyError):
        tp.get_data("non_existing_xpath")


@pytest.mark.unit
def test_xml_manifest_open_and_translate_errors(EMBEDED_TEST_DATA_FOLDER_UNIT):
    """Exercise XMLManifestAccessor open() and _translate_attributes() exception branches."""
    manifest_file = f"{EMBEDED_TEST_DATA_FOLDER_UNIT}/formatting/S3_*_1_xfdumanifest.xml"
    m = XMLManifestAccessor(manifest_file)
    # missing mapping
    with pytest.raises(MissingArgumentError):
        m.open(mode="r", namespaces={})
    # wrong mode string triggers OpeningMode.cast -> ValueError
    with pytest.raises(NotImplementedError):
        m.open(mode="WRONGMODE", namespaces={}, mapping={})
    # open with empty mapping so we can test translate without parsing
    m = XMLManifestAccessor(manifest_file)
    m.open(mode="r", namespaces={}, mapping={})
    with pytest.raises(AttributeError):
        m._translate_attributes({"a": "b"})


@pytest.mark.unit
def test_decode_function_from_target_type_not_implemented_with_real_xml(EMBEDED_TEST_DATA_FOLDER_UNIT):
    """Use a real xml file with XMLSingleFileAccessor and XMLMultipleFilesAccessor to hit NotImplementedError."""
    file_path = f"{EMBEDED_TEST_DATA_FOLDER_UNIT}/common/MTD_TL.xml"
    # Single file accessor
    sfa = XMLSingleFileAccessor(file_path)
    sfa.open(mode="r", target_type={"name": "unknown", "default_value": 0})
    with pytest.raises(NotImplementedError):
        sfa._decode_function_from_target_type()
    # Multiple files accessor
    mfa = XMLMultipleFilesAccessor(file_path)
    mfa.open(
        mode="r",
        source_order=["MTD_TL"],
        target_type={"name": "unknown", "default_value": 0},
    )
    with pytest.raises(NotImplementedError):
        mfa._decode_function_from_target_type()


@pytest.mark.unit
def test_singlefile_get_data_keyerror_with_real_xml(EMBEDED_TEST_DATA_FOLDER_UNIT):
    file_path = f"{EMBEDED_TEST_DATA_FOLDER_UNIT}/common/MTD_TL.xml"
    sfa = XMLSingleFileAccessor(file_path)
    sfa.open(mode="r", target_type={"name": "int32", "default_value": 0})
    with pytest.raises(KeyError):
        sfa.get_data("non_existing_xpath")


@pytest.mark.unit
def test_angles_s02_and_incidence_s02_keyerrors(EMBEDED_TEST_DATA_FOLDER_UNIT):
    """Check that S2 angle accessors raise KeyError for bad xpath using the S2 test xml."""
    s2_file = f"{EMBEDED_TEST_DATA_FOLDER_UNIT}/accessor/xml/S2B_MSIL1C_MTD_TL.xml"
    a = XMLAnglesAccessorS02(s2_file)
    a.open(mode="r", namespace={})
    with pytest.raises(NotImplementedError):
        a.write_data("bad_xpath", DataArray())
    i = XMLIncidenceAnglesAccessorS02(s2_file)
    i.open(mode="r", namespace={})
    with pytest.raises(KeyError):
        i.get_data("bad_xpath")
