import xml.etree.ElementTree as ET

import pytest
from defusedxml.ElementTree import fromstring

from eopf.store.product_specific.merge_l0_safe_manifests import merge_manifests

# HH Manifest (only differentiating elements change)
MANIFEST_HH_XML = """<?xml version="1.0" encoding="UTF-8"?>
<xfdu:XFDU xmlns:xfdu="urn:ccsds:schema:xfdu:1">
    <metadataSection>
        <metadataObject ID="generalProductInformation" classification="DESCRIPTION" category="DMD">
            <metadataWrap mimeType="text/xml" vocabularyName="SAFE">
                <xmlData>
                    <standAloneProductInformation>
                        <transmitterReceiverPolarisation>HH</transmitterReceiverPolarisation>
                        <packetStoreID>001</packetStoreID>
                        <byteOrder>LITTLE_ENDIAN</byteOrder>
                    </standAloneProductInformation>
                </xmlData>
            </metadataWrap>
        </metadataObject>
        <metadataObject ID="measurementQualityInformation" classification="DESCRIPTION" category="DMD">
            <metadataWrap mimeType="text/xml" vocabularyName="SAFE">
                <xmlData>
                    <qualityInformation>
                        <extension>
                            <qualityProperties>
                                <polarization>HH</polarization>
                                <qualityValue>0.95</qualityValue>
                            </qualityProperties>
                        </extension>
                    </qualityInformation>
                </xmlData>
            </metadataWrap>
        </metadataObject>
    </metadataSection>
    <dataObjectSection>
        <dataObject ID="measurementDataHH" repID="measurement">
            <byteStream mimeType="application/octet-stream">
                <fileLocation locatorType="URL" href="./s1a-iw-raw-s-hh-data.dat"/>
            </byteStream>
        </dataObject>
    </dataObjectSection>
</xfdu:XFDU>"""

# HV Manifest (only differentiating elements change)
MANIFEST_HV_XML = """<?xml version="1.0" encoding="UTF-8"?>
<xfdu:XFDU xmlns:xfdu="urn:ccsds:schema:xfdu:1">
    <metadataSection>
        <metadataObject ID="generalProductInformation" classification="DESCRIPTION" category="DMD">
            <metadataWrap mimeType="text/xml" vocabularyName="SAFE">
                <xmlData>
                    <standAloneProductInformation>
                        <transmitterReceiverPolarisation>HV</transmitterReceiverPolarisation>
                        <packetStoreID>002</packetStoreID>
                        <byteOrder>BIG_ENDIAN</byteOrder>
                    </standAloneProductInformation>
                </xmlData>
            </metadataWrap>
        </metadataObject>
        <metadataObject ID="measurementQualityInformation" classification="DESCRIPTION" category="DMD">
            <metadataWrap mimeType="text/xml" vocabularyName="SAFE">
                <xmlData>
                    <qualityInformation>
                        <extension>
                            <qualityProperties>
                                <polarization>HV</polarization>
                                <qualityValue>0.92</qualityValue>
                            </qualityProperties>
                        </extension>
                    </qualityInformation>
                </xmlData>
            </metadataWrap>
        </metadataObject>
    </metadataSection>
    <dataObjectSection>
        <dataObject ID="measurementDataHV" repID="measurement">
            <byteStream mimeType="application/octet-stream">
                <fileLocation locatorType="URL" href="./s1a-iw-raw-s-hv-data.dat"/>
            </byteStream>
        </dataObject>
    </dataObjectSection>
</xfdu:XFDU>"""

# Expected result with duplicated xmlData blocks
EXPECTED_MERGED_XML = """<?xml version="1.0" encoding="UTF-8"?>
<xfdu:XFDU xmlns:xfdu="urn:ccsds:schema:xfdu:1">
    <metadataSection>
        <metadataObject ID="generalProductInformation" classification="DESCRIPTION" category="DMD">
            <metadataWrap mimeType="text/xml" vocabularyName="SAFE">
                <xmlData>
                    <standAloneProductInformation>
                        <transmitterReceiverPolarisation>HH</transmitterReceiverPolarisation>
                        <packetStoreID>001</packetStoreID>
                        <byteOrder>LITTLE_ENDIAN</byteOrder>
                    </standAloneProductInformation>
                </xmlData>
                <xmlData>
                    <standAloneProductInformation>
                        <transmitterReceiverPolarisation>HV</transmitterReceiverPolarisation>
                        <packetStoreID>002</packetStoreID>
                        <byteOrder>BIG_ENDIAN</byteOrder>
                    </standAloneProductInformation>
                </xmlData>
            </metadataWrap>
        </metadataObject>
        <metadataObject ID="measurementQualityInformation" classification="DESCRIPTION" category="DMD">
            <metadataWrap mimeType="text/xml" vocabularyName="SAFE">
                <xmlData>
                    <qualityInformation>
                        <extension>
                            <qualityProperties>
                                <polarization>HH</polarization>
                                <qualityValue>0.95</qualityValue>
                            </qualityProperties>
                        </extension>
                    </qualityInformation>
                </xmlData>
                <xmlData>
                    <qualityInformation>
                        <extension>
                            <qualityProperties>
                                <polarization>HV</polarization>
                                <qualityValue>0.92</qualityValue>
                            </qualityProperties>
                        </extension>
                    </qualityInformation>
                </xmlData>
            </metadataWrap>
        </metadataObject>
    </metadataSection>
    <dataObjectSection>
        <dataObject ID="measurementDataHH" repID="measurement">
            <byteStream mimeType="application/octet-stream">
                <fileLocation locatorType="URL" href="./s1a-iw-raw-s-hh-data.dat"/>
            </byteStream>
        </dataObject>
        <dataObject ID="measurementDataHV" repID="measurement">
            <byteStream mimeType="application/octet-stream">
                <fileLocation locatorType="URL" href="./s1a-iw-raw-s-hv-data.dat"/>
            </byteStream>
        </dataObject>
    </dataObjectSection>
</xfdu:XFDU>"""


class TestL0MergeIwManifests:
    """Unit test for IW manifest merging with xmlData block duplication."""

    @pytest.mark.unit
    def test_merge_manifests_duplicate_xmldata_blocks(self) -> None:
        """Test merging two manifests by duplicating complete xmlData blocks."""

        # Parse input manifests
        manifest_hh = ET.ElementTree(fromstring(MANIFEST_HH_XML))
        manifest_hv = ET.ElementTree(fromstring(MANIFEST_HV_XML))

        # Merge manifests
        merged_manifest = merge_manifests(manifest_hh, manifest_hv)
        merged_root = merged_manifest.getroot()

        # Specific verifications for xmlData block duplication

        # 1. Verify there are 2 xmlData blocks in generalProductInformation
        general_xmldata_blocks = merged_root.findall(
            ".//metadataObject[@ID='generalProductInformation']/metadataWrap/xmlData",
        )
        assert len(general_xmldata_blocks) == 2, (
            f"Expected 2 xmlData blocks for generalProductInformation, got {len(general_xmldata_blocks)}"
        )

        # 2. Verify there are 2 xmlData blocks in measurementQualityInformation
        quality_xmldata_blocks = merged_root.findall(
            ".//metadataObject[@ID='measurementQualityInformation']/metadataWrap/xmlData",
        )
        assert len(quality_xmldata_blocks) == 2, (
            f"Expected 2 xmlData blocks for measurementQualityInformation, got {len(quality_xmldata_blocks)}"
        )

        # 3. Verify each xmlData block contains its complete polarization
        polarizations_in_blocks = []
        for block in general_xmldata_blocks:
            pol_elem = block.find(".//transmitterReceiverPolarisation")
            if pol_elem is not None:
                polarizations_in_blocks.append(pol_elem.text)

        assert set(polarizations_in_blocks) == {
            "HH",
            "HV",
        }, f"Incorrect polarizations in xmlData blocks: {polarizations_in_blocks}"

        # 4. Verify each block has its own packet store IDs
        packet_ids_in_blocks = []
        for block in general_xmldata_blocks:
            packet_elem = block.find(".//packetStoreID")
            if packet_elem is not None:
                packet_ids_in_blocks.append(packet_elem.text)

        assert set(packet_ids_in_blocks) == {
            "001",
            "002",
        }, f"Incorrect packet store IDs in xmlData blocks: {packet_ids_in_blocks}"

        # 5. Verify quality blocks are duplicated correctly
        quality_polarizations = []
        for block in quality_xmldata_blocks:
            pol_elem = block.find(".//polarization")
            if pol_elem is not None:
                quality_polarizations.append(pol_elem.text)

        assert set(quality_polarizations) == {
            "HH",
            "HV",
        }, f"Incorrect polarizations in quality blocks: {quality_polarizations}"

        # 6. Verify data objects are correctly merged
        data_objects = merged_root.findall(".//dataObject")
        assert len(data_objects) == 2, f"Expected 2 data objects, got {len(data_objects)}"

        data_object_ids = [obj.get("ID") for obj in data_objects]
        assert set(data_object_ids) == {
            "measurementDataHH",
            "measurementDataHV",
        }, f"Incorrect data object IDs: {data_object_ids}"
