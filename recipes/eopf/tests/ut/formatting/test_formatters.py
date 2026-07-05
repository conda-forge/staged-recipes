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
from typing import Any

import numpy as np
import pytest
from shapely import MultiPolygon, Polygon

from eopf.common import xml_utils
from eopf.exceptions import FormattingError
from eopf.formatting.formatters_factory import EOFormatterFactory
from eopf.formatting.utils import (
    detect_pole_or_antemeridian,
    poly_coords_parsing,
    split_poly,
)
from eopf.formatting.xml_formatters import ToPosList


@pytest.mark.unit
@pytest.mark.parametrize(
    "string, result",
    [
        ("to_str(machin)", "machin"),
        ("to_float(1.23)", 1.23),
        ("to_float(0)", 0),
        ("to_float(-1.23)", -1.23),
        ("to_float(-inf)", float("-inf")),
        ("to_int(10)", 10),
        ("to_int(0)", 0),
        ("to_int(-1)", -1),
        ("to_int(123.456)", 123),
        ("to_bool(true)", True),
        ("to_bool(false)", False),
        ("to_bool(1)", True),
        ("to_bool(0)", False),
        ("to_bool(defined)", True),
        ("is_optional(machin)", "machin"),
        ("is_optional()", "null"),
        ("is_optional(to_int(1))", 1),
        ("is_optional(to_int(0))", 0),
        ("is_optional(0)", "0"),
        ("is_optional(-123.456)", "-123.456"),
        ("is_optional(to_float(-inf))", float("-inf")),
        ("to_microm_from_nanom(1000)", 1),
        ("to_str(machin)", "machin"),
        ("to_str_lower(to_str(MACHIN))", "machin"),
        ("to_int(to_float(1.23))", 1),
        ("to_str(to_int(10))", "10"),
        ("to_int(to_bool(true))", 1),
        ("to_int(to_bool(false))", 0),
        ("to_str(to_microm_from_nanom(100))", "0.1"),
    ],
)
def test_basic_formatters(string: str, result: Any):
    name, formatter, subpath = EOFormatterFactory().get_formatter(string)
    print(name)
    print(formatter)
    print(subpath)
    if formatter:
        assert formatter.format(subpath) == result


@pytest.mark.unit
@pytest.mark.parametrize(
    "string",
    [
        ("to_float(machin)"),
        ("to_int(machin)"),
        ("to_microm_from_nanom(machin)"),
        ("to_str(to_float(machin))"),
        ("to_str(to_int(machin))"),
        ("to_str(to_microm_from_nanom(machin))"),
    ],
)
def test_basic_formatters_errors(string: str):
    name, formatter, subpath = EOFormatterFactory().get_formatter(string)
    print(name)
    print(formatter)
    print(subpath)
    with pytest.raises(FormattingError):
        formatter.format(subpath)


"""
Date format
"""


@pytest.mark.unit
@pytest.mark.parametrize(
    "string, result",
    [
        ("to_unix_time(2012-11-10)", 1352505600000000),
        ("to_ISO8601(20230101T010101)", "2023-01-01T01:01:01Z"),
    ],
)
def test_date_formatters(string: str, result: Any):
    name, formatter, subpath = EOFormatterFactory().get_formatter(string)
    print(name)
    print(formatter)
    print(subpath)
    if formatter:
        assert formatter.format(subpath) == result


"""
To_number format
"""


@pytest.mark.unit
@pytest.mark.parametrize(
    "string, result",
    [
        ("auto(342423.54)", 342423.54),
        ("auto(-0.6542)", -0.6542),
        ("auto(123.4364568913)", 123.4364568913),
        ("auto(32)", 32),
        ("auto(4397820185)", 4397820185),
        ("auto(True)", True),
        ("auto(False)", False),
        ("auto(None)", None),
        ("auto('spectral_position')", "spectral_position"),
    ],
)
def test_auto_formatters(string: str, result: Any):
    name, formatter, subpath = EOFormatterFactory().get_formatter(string)
    if formatter:
        assert formatter.format(subpath) == result


"""
To_number format
"""


@pytest.mark.unit
@pytest.mark.parametrize(
    "string, result",
    [
        ("to_number(342423.54)", 342423.54),
        ("to_number(22132)", 22132),
        ("to_number(124)", 124),
        ("to_number(0)", 0),
        ("to_number(255)", np.uint8("255")),
        ("to_number(65535)", np.uint16("65535")),
        ("to_number(4294967295)", np.uint32("4294967295")),
        ("to_number(18446744073709551615)", np.uint64("18446744073709551615")),
        ("to_number(-127)", np.int8("-127")),
        ("to_number(-32767)", np.int16("-32767")),
        ("to_number(-2147483647)", np.int32("-2147483647")),
        ("to_number(-9223372036854775807)", np.int64("-9223372036854775807")),
        ("to_number(-6.104e-05)", np.float16("-6.104e-05")),
        ("to_number(1.65765)", np.float32("1.65765")),
        ("to_number(5.326789641462432)", np.float64("5.326789641462432")),
        # longdouble ~ float128 | it is represented on 80 or 128 bits, depends on the machine's system
        ("to_number(7.45210760658921357)", np.longdouble("7.45210760658921357")),
        ("to_number(1+2j)", np.complex128("1+2j")),
    ],
)
def test_to_number_formatters(string: str, result: Any):
    name, formatter, subpath = EOFormatterFactory().get_formatter(string)
    if formatter:
        assert formatter.format(subpath) == result


"""
 geometry formatters
"""


@pytest.mark.unit
@pytest.mark.parametrize(
    "string, result",
    [
        (
            "to_bbox(60.3312963250542 29.048924522552475 60.3694075001592 29.072396890743008 "
            "60.51315047701044 29.161246126341577 60.65682332139564 29.250775771571814 "
            "60.80046946417681 29.340854384748308 60.94401494844166 29.43128700669155"
            " 61.087499540757776 29.522528992132887 61.23101195527686 29.61488329645271"
            " 61.30466816531411 29.662593483351475 61.27798036451517 30.914902973234536 "
            "60.294406065684655 30.796545293721568 60.3312963250542 29.048924522552475 )",
            [30.914902973234536, 60.294406065684655, 29.048924522552475, 61.30466816531411],
        ),
        (
            "to_geoJson(60.3312963250542 29.048924522552475 60.3694075001592 29.072396890743008 "
            "60.51315047701044 29.161246126341577 60.65682332139564 29.250775771571814 "
            "60.80046946417681 29.340854384748308 60.94401494844166 29.43128700669155"
            " 61.087499540757776 29.522528992132887 61.23101195527686 29.61488329645271"
            " 61.30466816531411 29.662593483351475 61.27798036451517 30.914902973234536 "
            "60.294406065684655 30.796545293721568 60.3312963250542 29.048924522552475 )",
            dict(
                type="Polygon",
                coordinates=[
                    [
                        [29.048924522552475, 60.3312963250542],
                        [29.072396890743008, 60.3694075001592],
                        [29.161246126341577, 60.51315047701044],
                        [29.250775771571814, 60.65682332139564],
                        [29.340854384748308, 60.80046946417681],
                        [29.43128700669155, 60.94401494844166],
                        [29.522528992132887, 61.087499540757776],
                        [29.61488329645271, 61.23101195527686],
                        [29.662593483351475, 61.30466816531411],
                        [30.914902973234536, 61.27798036451517],
                        [30.796545293721568, 60.294406065684655],
                        [29.048924522552475, 60.3312963250542],
                    ],
                ],
            ),
        ),
    ],
)
def test_geometry_formatters(string: str, result: Any):
    name, formatter, subpath = EOFormatterFactory().get_formatter(string)
    print(name)
    print(formatter)
    print(subpath)
    if formatter:
        print(formatter.format(subpath))
        assert formatter.format(subpath) == result


"""
xml formatters
"""


@pytest.mark.unit
@pytest.mark.parametrize(
    "string, result",
    [
        (
            "to_bands(n1:Geometric_Info/Tile_Angles/Viewing_Incidence_Angles_Grids)",
            ["b01", "b02"],
        ),
        (
            "to_detectors(n1:Geometric_Info/Tile_Angles/Viewing_Incidence_Angles_Grids)",
            ["d01", "d02"],
        ),
    ],
)
def test_xml_formatters(EMBEDED_TEST_DATA_FOLDER_UNIT, string: str, result: Any):
    name, formatter, subpath = EOFormatterFactory().get_formatter(string)
    root = xml_utils.parse_xml(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "common", "MTD_TL.xml"))
    print(name)
    print(formatter)
    print(subpath)
    if formatter:
        xpath_results = xml_utils.get_xpath_results(
            root,
            subpath,
            namespaces=xml_utils.get_namespaces(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "common", "MTD_TL.xml")),
        )
        print(formatter.format(xpath_results))
        assert formatter.format(xpath_results) == result


@pytest.mark.unit
@pytest.mark.parametrize(
    "xml_string, formatter_path, result",
    [
        (
            b"""<?xml version="1.0" encoding="UTF-8"?>
<xfdu:XFDU version="esa/safe/sentinel-1.0/sentinel-1/sar/level-0/standard/ewdp"
   xmlns:s1="http://www.esa.int/safe/sentinel-1.0/sentinel-1"
   xmlns:s1sar="http://www.esa.int/safe/sentinel-1.0/sentinel-1/sar"
   xmlns:xfdu="urn:ccsds:schema:xfdu:1">
   <metadataSection>
      <metadataObject ID="acquisitionPeriod" classification="DESCRIPTION" category="DMD">
         <metadataWrap mimeType="text/xml" vocabularyName="SAFE" textInfo="Acquisition Period">
            <xmlData>
               <acquisitionPeriod xmlns="http://www.esa.int/safe/sentinel-1.0">
                  <startTime>2022-11-11T11:46:57.159065Z</startTime>
                  <stopTime>2022-11-11T11:47:58.746544Z</stopTime>
                  <extension>
                     <s1:timeANX>
                        <s1:startTimeANX>1760475.1920</s1:startTimeANX>
                        <s1:stopTimeANX>1822062.6710</s1:stopTimeANX>
                     </s1:timeANX>
                  </extension>
               </acquisitionPeriod>
            </xmlData>
         </metadataWrap>
      </metadataObject>
   </metadataSection>
</xfdu:XFDU>""",
            "to_datetime(metadataSection/metadataObject[@ID='acquisitionPeriod']/metadataWrap"
            "/xmlData/*[local-name() = 'acquisitionPeriod']/*[contains(local-name(), 'Time')])",
            "2022-11-11T11:47:27.952805Z",
        ),
        (
            b"""<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<n1:Level-2A_User_Product
  xmlns:n1="https://psd-15.sentinel2.eo.esa.int/PSD/User_Product_Level-2A.xsd"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="https://psd-15.sentinel2.eo.esa.int/PSD/User_Product_Level-2A.xsd">
  <n1:General_Info>
    <Product_Info>
      <PRODUCT_START_TIME>2024-08-26T10:25:59.024Z</PRODUCT_START_TIME>
      <PRODUCT_STOP_TIME>2024-08-26T10:42:42.123Z</PRODUCT_STOP_TIME>
    </Product_Info>
  </n1:General_Info>
</n1:Level-2A_User_Product>""",
            "to_datetime(n1:General_Info/Product_Info/*[contains(local-name(), '_TIME')])",
            "2024-08-26T10:34:20.573500Z",
        ),
        (
            b"""<?xml version="1.0" encoding="UTF-8"?>
<xfdu:XFDU xmlns:xfdu="urn:ccsds:schema:xfdu:1"
  xmlns:sentinel-safe="http://www.esa.int/safe/sentinel/1.1" xmlns:gml="http://www.opengis.net/gml"
  xmlns:sentinel3="http://www.esa.int/safe/sentinel/sentinel-3/1.0"
  xmlns:s3-level0="http://www.esa.int/safe/sentinel/sentinel-3/level-0/1.0"
  version="esa/safe/sentinel/sentinel-3/level-0/1.0">
  <metadataSection>
    <metadataObject ID="acquisitionPeriod" classification="DESCRIPTION" category="DMD">
      <metadataWrap mimeType="text/xml" vocabularyName="Sentinel-SAFE" textInfo="Acquisition Period">
        <xmlData>
          <sentinel-safe:acquisitionPeriod>
            <sentinel-safe:startTime>2024-01-10T11:27:33.123456Z</sentinel-safe:startTime>
            <sentinel-safe:stopTime>2024-01-10T13:07:25.789123Z</sentinel-safe:stopTime>
          </sentinel-safe:acquisitionPeriod>
        </xmlData>
      </metadataWrap>
    </metadataObject>
  </metadataSection>
</xfdu:XFDU>""",
            "to_datetime(metadataSection/metadataObject[@ID='acquisitionPeriod']/metadataWrap"
            "/xmlData/*[local-name() = 'acquisitionPeriod']/*[contains(local-name(), 'Time')])",
            "2024-01-10T12:17:29.456290Z",
        ),
    ],
)
def test_xml_datetime_formatter(xml_string: bytes, formatter_path: str, result: str):
    root = xml_utils.etree.fromstring(xml_string)
    name, formatter, subpath = EOFormatterFactory().get_formatter(formatter_path)
    assert name == formatter_path[: formatter_path.index("(")]
    xpath_results = xml_utils.get_xpath_results(root, subpath, namespaces=root.nsmap)
    formatter_result = formatter.format(xpath_results)
    assert result == formatter_result


@pytest.mark.unit
@pytest.mark.parametrize(
    "string, result",
    [
        (
            "to_processing_history(metadataSection/metadataObject[@ID='processing']/"
            "metadataWrap/xmlData/sentinel-safe:processing)",
            [0, 1],
        ),
    ],
)
def test_xml_to_history_formatters(EMBEDED_TEST_DATA_FOLDER_UNIT, string: str, result: Any):
    name, formatter, subpath = EOFormatterFactory().get_formatter(string)
    root = xml_utils.parse_xml(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "formatting", "S3_OL_1_xfdumanifest.xml"))
    print(name)
    print(formatter)
    print(subpath)
    if formatter:
        xpath_results = xml_utils.get_first_xpath_result(
            root,
            subpath,
            namespaces=xml_utils.get_namespaces(
                os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "formatting", "S3_OL_1_xfdumanifest.xml"),
            ),
        )
        print(xpath_results)
        print(
            formatter.format(
                (
                    xpath_results,
                    xml_utils.get_namespaces(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "formatting", "S3_OL_1_xfdumanifest.xml")),
                    "S3A_OL_0_EFR____20200101T100749_20200101T"
                    "100947_20200101T115148_0118_053_179______LN1_O_NR_002.SEN3",
                    "S3A_OL_0_EFR____20200101T100749_202"
                    "00101T100947_20200101T115148_0118_053_179______LN1_O_NR_002.SEN3",
                ),
            ),
        )
        assert (
            len(
                formatter.format(
                    (
                        xpath_results,
                        xml_utils.get_namespaces(
                            os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "formatting", "S3_OL_1_xfdumanifest.xml"),
                        ),
                        "S3A_OL_0_EFR____20200101T100749_20200"
                        "101T100947_20200101T115148_0118_053_179______LN1_O_NR_002.SEN3",
                        "S3A_OL_0_EFR____20200101T100749_20200101"
                        "T100947_20200101T115148_0118_053_179______LN1_O_NR_002.SEN3",
                    ),
                ),
            )
            != 0
        )


@pytest.mark.unit
def test_to_pos_list(EMBEDED_TEST_DATA_FOLDER_UNIT):
    root = xml_utils.parse_xml(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "formatting", "S3_OL_1_xfdumanifest.xml"))
    formatter = ToPosList()
    array = formatter.format(
        xml_utils.get_xpath_results(
            root,
            "metadataSection/metadataObject[@ID='measurementFrameSet']"
            "/metadataWrap/xmlData/sentinel-safe:frameSet/sentinel-safe:footPrint/gml:posList",
            namespaces=xml_utils.get_namespaces(
                os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "formatting", "S3_OL_1_xfdumanifest.xml"),
            ),
        ),
    )
    print(array)
    assert len(array) != 0
    assert (
        array == "POLYGON((-10.6835 20.9433, -10.0248 20.8354, -9.37138 20.7263, -8.71718 20.6145, -8.06782 20.5009,"
        " -7.41715 20.3845, -6.76811 20.2659, -6.1183 20.1445, -5.47326 20.0212, -4.82477 19.8947, -4.17966 "
        "19.7713, -3.53473 19.6403, -2.89205 19.51, -2.24937 19.3718, -1.60894 19.2346, -0.968598 19.0923,"
        " -0.329523 18.9517, 0.307983 18.808, 0.94649 18.6615, 1.58295 18.513, 2.2777 21.1536, 2.99949 23.7956,"
        " 3.75074 26.4344, 4.53553 29.0688, 3.84923 29.2284, 3.15794 29.385, 2.46989 29.5367, 1.7763 29.6846,"
        " 1.08054 29.8328, 0.38391 29.9743, -0.3129 30.1149, -1.01316 30.2467, -1.71348 30.3771, -2.42105 30.4997, "
        "-3.12531 30.6225, -3.83364 30.7419, -4.54105 30.8566, -5.24906 30.9674, -5.95232 31.0734, -6.66744 31.1771,"
        " -7.37524 31.2756, -8.11174 31.3738, -8.8395 31.4669, -9.28791 28.8363, -9.74467 26.2042, -10.21 23.5717,"
        " -10.6835 20.9433))"
    )


@pytest.mark.unit
def test_poly_coords_parsing_basic_and_with_commas():
    # Normal space-separated input
    s = "10 20 30 40"
    result = poly_coords_parsing(s)
    assert result == [[20.0, 10.0], [40.0, 30.0]]

    # Input with commas between lat/lon and extra spaces
    s = " 10,20   30,40 "
    result = poly_coords_parsing(s)
    assert result == [[20.0, 10.0], [40.0, 30.0]]


@pytest.mark.unit
def test_poly_coords_parsing_handles_odd_number_of_values():
    # If odd number of coordinates, the last one is ignored
    s = "10 20 30"  # last single coordinate is dropped
    result = poly_coords_parsing(s)
    assert result == [[20.0, 10.0]]


@pytest.mark.unit
def test_detect_pole_or_antemeridian_no_crossing():
    # Points with small longitude differences
    coords = [[0, 0], [10, 10], [20, 20]]
    assert not detect_pole_or_antemeridian(coords)


@pytest.mark.unit
def test_detect_pole_or_antemeridian_with_crossing():
    # Jump from longitude -170 to 170 => 340 deg difference > 270
    coords = [[0, -170], [0, 170]]
    assert detect_pole_or_antemeridian(coords)


@pytest.mark.unit
def test_split_poly_no_crossing_returns_multipolygon():
    """A polygon fully inside -180..180 returns a MultiPolygon whose union covers the input polygon."""
    poly = Polygon([(-10, -10), (10, -10), (10, 10), (-10, 10), (-10, -10)])
    mp = split_poly(poly)
    assert isinstance(mp, MultiPolygon)
    # Ensure every geometry is valid and union covers input polygon
    assert mp.is_valid
    # Its union should at least cover the original polygon (it may be slightly larger)
    assert mp.union(poly).covers(poly)


@pytest.mark.unit
def test_split_poly_no_crossing_returns_valid_multipolygon():
    """Polygon completely inside [-180,180] yields a valid MultiPolygon."""
    poly = Polygon([(-10, -10), (10, -10), (10, 10), (-10, 10), (-10, -10)])
    mp = split_poly(poly)
    assert isinstance(mp, MultiPolygon)
    assert mp.is_valid
    # At least one geometry with positive area
    assert any(g.area > 0 for g in mp.geoms)


@pytest.mark.unit
def test_split_poly_crossing_antemeridian_returns_valid_multipolygon():
    """Polygon crossing the antimeridian yields a valid MultiPolygon (at least 2 parts)."""
    poly = Polygon([(170, -10), (-170, -10), (-170, 10), (170, 10), (170, -10)])
    mp = split_poly(poly)
    assert isinstance(mp, MultiPolygon)
    assert mp.is_valid
    # It should contain at least two geometries (even if small)
    assert len(mp.geoms) >= 2
    assert any(g.area > 0 for g in mp.geoms)


@pytest.mark.unit
def test_split_poly_touching_antemeridian_raises_typeerror():
    """Polygon merely touching the antimeridian triggers TypeError due to LineString inside MultiPolygon."""
    poly = Polygon([(179, -10), (180, -10), (180, 10), (179, 10), (179, -10)])
    with pytest.raises(TypeError):
        split_poly(poly)
