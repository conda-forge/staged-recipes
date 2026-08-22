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
import os.path
from pathlib import Path

import pytest

from eopf.common import xml_utils
from eopf.common.xml_utils import get_xpath_results, parse_xml


@pytest.fixture
def xml_utils_data(EMBEDED_TEST_DATA_FOLDER_UNIT: Path) -> Path:
    return EMBEDED_TEST_DATA_FOLDER_UNIT / "common"


@pytest.mark.unit
def test_parse_xml(xml_utils_data):
    xml_utils.parse_xml(os.path.join(xml_utils_data, "MTD_TL.xml"))


@pytest.mark.unit
def test_get_namespaces(xml_utils_data):
    print(xml_utils.get_namespaces(os.path.join(xml_utils_data, "MTD_TL.xml")))
    assert len(xml_utils.get_namespaces(os.path.join(xml_utils_data, "MTD_TL.xml"))) != 0


@pytest.mark.unit
def test_get_xpath_results(xml_utils_data):
    root = xml_utils.parse_xml(os.path.join(xml_utils_data, "MTD_TL.xml"))
    assert (
        len(
            xml_utils.get_xpath_results(
                root,
                "n1:Geometric_Info/Tile_Angles/Viewing_Incidence_Angles_Grids",
                namespaces=xml_utils.get_namespaces(os.path.join(xml_utils_data, "MTD_TL.xml")),
            ),
        )
        != 0
    )


@pytest.mark.unit
def test_get_first_xpath_result(xml_utils_data):
    root = xml_utils.parse_xml(os.path.join(xml_utils_data, "MTD_TL.xml"))
    assert (
        xml_utils.get_first_xpath_result(
            root,
            "n1:Geometric_Info/Tile_Angles/Viewing_Incidence_Angles_Grids",
            namespaces=xml_utils.get_namespaces(os.path.join(xml_utils_data, "MTD_TL.xml")),
        )
        is not None
    )


@pytest.mark.unit
def test_get_text(xml_utils_data):
    root = xml_utils.parse_xml(os.path.join(xml_utils_data, "MTD_TL.xml"))
    assert (
        xml_utils.get_text(
            xml_utils.get_first_xpath_result(
                root,
                "n1:Geometric_Info/Tile_Geocoding/HORIZONTAL_CS_NAME",
                namespaces=xml_utils.get_namespaces(os.path.join(xml_utils_data, "MTD_TL.xml")),
            ),
        )
        == "WGS84 / UTM zone 34N"
    )


@pytest.mark.unit
def test_get_values_as_xr_dataarray(xml_utils_data):
    root = xml_utils.parse_xml(os.path.join(xml_utils_data, "MTD_TL.xml"))
    array = xml_utils.get_values_as_xr_dataarray(
        xml_utils.get_first_xpath_result(
            root,
            "n1:Geometric_Info/Tile_Angles/Sun_Angles_Grid/Zenith/Values_List",
            namespaces=xml_utils.get_namespaces(os.path.join(xml_utils_data, "MTD_TL.xml")),
        ),
        "n1:Geometric_Info/Tile_Angles/Sun_Angles_Grid/Zenith/Values_List",
        namespaces=xml_utils.get_namespaces(os.path.join(xml_utils_data, "MTD_TL.xml")),
    )
    assert len(array["y_tiepoints"]) == 23
    assert len(array["x_tiepoints"]) == 23


@pytest.fixture
def tree(xml_utils_data: Path):
    snippet_path = xml_utils_data / "snippet_xfdumanifest.xml"
    with open(snippet_path) as f:
        return parse_xml(f)


@pytest.mark.unit
def test_parse_xml_bis(tree, xml_utils_data):
    """Given an input xml,
    the output of the function must match the expected output"""
    result = ""
    display_namespaces = True
    for element in tree.iter():
        tag = element.tag
        result += f"{tag}\n"
        if display_namespaces:
            display_namespaces = False
            for key, value in element.nsmap.items():
                result += f"{key} : {value}\n"
        attributes = element.attrib
        for key, value in attributes.items():
            result += f"{key} : {value}\n"
        textual_content = element.text
        if textual_content and textual_content.strip():
            result += textual_content + "\n"
    file_path = xml_utils_data / "solutions.txt"
    with open(file_path, "r") as f:
        expected = f.read()
    assert result == expected


@pytest.mark.unit
def test_apply_xpath(tree):
    """Given an input xml,
    the output of the function must match the expected output"""
    MAP = {
        "title": "concat('',metadataSection/metadataObject[@ID='generalProductInformation']/metadataWrap/xmlData/"
        "sentinel3:generalProductInformation/sentinel3:productName/text())",
        "Conventions": "'CF-1.9'",
    }
    NAMESPACES = {
        "xfdu": "urn:ccsds:schema:xfdu:1",
        "gml": "http://www.opengis.net/gml",
        "sentinel-safe": "http://www.esa.int/safe/sentinel/1.1",
        "sentinel3": "http://www.esa.int/safe/sentinel/sentinel-3/1.0",
        "olci": "http://www.esa.int/safe/sentinel/sentinel-3/olci/1.0",
    }
    result = {attr: get_xpath_results(tree, MAP[attr], NAMESPACES) for attr in MAP}
    assert result == {
        "title": "S3A_OL_1_EFR____20220116T092821_20220116T093121_20220117T134858_0179_081_036_2160_LN1_O_NT_002.SEN3",
        "Conventions": "CF-1.9",
    }
