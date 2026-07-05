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

import numpy
import pytest

from eopf import EOConfiguration
from eopf.accessor.memmap_accessors import (
    FixedMemMapAccessor,
    MemMapAccessor,
    MemMapToAttrAccessor,
    MultipleFilesMemMapAccessor,
)
from eopf.common.file_utils import AnyPath
from eopf.exceptions.errors import (
    AccessorInvalidMappingParameters,
    AccessorRetrieveError,
    MissingArgumentError,
)

pytestmark = pytest.mark.dask_only
pytest.importorskip("dask")


@pytest.mark.unit
def test_fixed_memmap_strip_config():
    config = {"target_type": "uint16", "machin": "truc"}

    new_conf = FixedMemMapAccessor.strip_config(config)

    assert len(new_conf) == 1
    assert "machin" in new_conf.keys()
    assert "target_type" not in new_conf.keys()


@pytest.mark.unit
def test_fixed_memmap_properties(EMBEDED_TEST_DATA_FOLDER_UNIT: str):
    memmap_accesssor = FixedMemMapAccessor(
        os.path.join(
            EMBEDED_TEST_DATA_FOLDER_UNIT,
            "accessor",
            "MemMap_s1a-ew-raw-s-hh-20230103t225516-20230103t225554-046625-059698-index.dat",
        ),
        packet_length_bytes=26,
    )

    memmap_accesssor.set_config({"target_type": "uint16", "machin": "truc"})
    assert memmap_accesssor._target_type == "uint16"


@pytest.mark.unit
def test_fixed_memmap_error_cases(EMBEDED_TEST_DATA_FOLDER_UNIT: str):
    # File not found
    with pytest.raises(FileNotFoundError):
        memmap_accessor = FixedMemMapAccessor(
            os.path.join(
                EMBEDED_TEST_DATA_FOLDER_UNIT,
                "accessor",
                "Machinbidule.dat",
            ),
            packet_length_bytes=26,
        )
        memmap_accessor.open(target_type="uint16")
    # Missing conf param
    with pytest.raises(MissingArgumentError):
        memmap_accessor = FixedMemMapAccessor(
            os.path.join(
                EMBEDED_TEST_DATA_FOLDER_UNIT,
                "accessor",
                "Machinbidule.dat",
            ),
        )
        memmap_accessor.open(target_type="uint16")
    # Missing type param
    with pytest.raises(MissingArgumentError):
        memmap_accessor = FixedMemMapAccessor(
            os.path.join(
                EMBEDED_TEST_DATA_FOLDER_UNIT,
                "accessor",
                "Machinbidule.dat",
            ),
            packet_length_bytes=26,
        )
        memmap_accessor.open()
    # not an attr accessor
    with pytest.raises(NotImplementedError):
        memmap_accessor = FixedMemMapAccessor(
            os.path.join(
                EMBEDED_TEST_DATA_FOLDER_UNIT,
                "accessor",
                "Machinbidule.dat",
            ),
            packet_length_bytes=26,
        )
        memmap_accessor.write_attrs("", dict())


@pytest.mark.unit
def test_fixed_memmap_open_uint16(EMBEDED_TEST_DATA_FOLDER_UNIT: str):
    fixed_memmap_accesssor = FixedMemMapAccessor(
        os.path.join(
            EMBEDED_TEST_DATA_FOLDER_UNIT,
            "accessor",
            "FixedMemMap_s1a-ew-raw-s-hh-20230103t225516-20230103t225554-046625-059698-annot.dat",
        ),
        packet_length_bytes=26,
    )

    fixed_memmap_accesssor.open(target_type="uint16")
    numpy_array = fixed_memmap_accesssor.get_data("(0,16)").compute()
    assert numpy_array[0] == 8403
    assert numpy_array.shape[0] == 66808
    fixed_memmap_accesssor.close()


@pytest.mark.unit
def test_fixed_memmap_open_scalar(EMBEDED_TEST_DATA_FOLDER_UNIT: str):
    fixed_memmap_accesssor = FixedMemMapAccessor(
        os.path.join(
            EMBEDED_TEST_DATA_FOLDER_UNIT,
            "accessor",
            "FixedMemMap_s1a-ew-raw-s-hh-20230103t225516-20230103t225554-046625-059698-annot.dat",
        ),
        packet_length_bytes=26,
    )

    fixed_memmap_accesssor.open(target_type="s_uint8")
    numpy_array = fixed_memmap_accesssor.get_data("(192,194)").compute()
    assert numpy_array[0] == 1
    assert numpy_array.shape[0] == 1  # scalar call
    fixed_memmap_accesssor.close()


@pytest.mark.unit
@pytest.mark.real_s3
def test_fixed_memmap_open_scalar_s3(EMBEDED_TEST_DATA_FOLDER_UNIT: str, s3_test_data, s3_config_real):
    fixed_memmap_accesssor = FixedMemMapAccessor(
        AnyPath(
            f"{s3_test_data[0]}://{s3_test_data[1]}"
            f"/embedbed/FixedMemMap_s1a-ew-raw-s-hh-20230103t225516-20230103t225554-046625-059698-annot.dat",
            **dict(s3_config_real),
        ),
        packet_length_bytes=26,
    )

    fixed_memmap_accesssor.open(target_type="s_uint8")
    numpy_array = fixed_memmap_accesssor.get_data("(192,194)").compute()
    assert numpy_array[0] == 1
    assert numpy_array.shape[0] == 1  # scalar call
    fixed_memmap_accesssor.close()


@pytest.mark.unit
def test_fixed_memmap_open_bytearray(EMBEDED_TEST_DATA_FOLDER_UNIT: str):
    fixed_memmap_accesssor = FixedMemMapAccessor(
        os.path.join(
            EMBEDED_TEST_DATA_FOLDER_UNIT,
            "accessor",
            "FixedMemMap_S3A_OL_0_EFR_ISPAnnotation.dat",
        ),
        packet_length_bytes=30,
    )

    fixed_memmap_accesssor.open(target_type="bytearray")
    numpy_array = fixed_memmap_accesssor.get_data("(0,144)").compute()
    assert numpy_array.shape[1] == 18
    assert numpy_array.shape[0] == 13635
    print(numpy_array[0])
    assert numpy.allclose(numpy_array[0], [0, 0, 30, 170, 0, 0, 67, 251, 0, 3, 190, 187, 30, 170, 1, 83, 17, 122])
    fixed_memmap_accesssor.close()


@pytest.mark.unit
def test_fixed_memmap_write_uint16(OUTPUT_DIR):
    memmap_accesssor = FixedMemMapAccessor(
        os.path.join(
            OUTPUT_DIR,
            "test_memmap.dat",
        ),
        packet_length_bytes=30,
    )
    memmap_accesssor.open(mode="w", target_type="uint16")
    memmap_accesssor._reconversion_attrs = numpy.asarray([32, 32, 32, 32, 32], dtype=numpy.uint8)
    param = numpy.zeros((len(memmap_accesssor._reconversion_attrs),), dtype="B")
    memmap_accesssor.write_data("(0,16,16)", param)


@pytest.mark.unit
def test_memmap_to_attr(EMBEDED_TEST_DATA_FOLDER_UNIT: str):
    memmap_to_att_accessor = MemMapToAttrAccessor(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "accessor"))

    memmap_kwargs = {
        "primary_header_length_bytes": 6,
        "ancillary_header_length_bytes": 0,
        "packet_length_start_position_bytes": 4,
        "packet_length_stop_position_bytes": 6,
        "mapping": {
            "hh_receive_channel_id": "FixedMemMap_s1a-ew-raw-s-hh-20230103t225516-20230103t225554-046625-"
            "059698-annot.dat:(172,176):scalar_uint8",
        },
        "types_mapping": {"scalar_uint8": "s_uint8"},
    }

    memmap_to_att_accessor.open(mode="r", **memmap_kwargs)
    assert len(memmap_to_att_accessor.get_data("/").attrs) == 1
    assert memmap_to_att_accessor.get_data("/").attrs["hh_receive_channel_id"] == 0
    memmap_to_att_accessor.close()


@pytest.mark.unit
def test_memmap_to_attr_error_cases(EMBEDED_TEST_DATA_FOLDER_UNIT: str):
    # File not found
    with pytest.raises(IOError):
        memmap_to_att_accessor = MemMapToAttrAccessor("/tmp/nothing/")

        memmap_kwargs = {
            "primary_header_length_bytes": 6,
            "ancillary_header_length_bytes": 0,
            "packet_length_start_position_bytes": 4,
            "packet_length_stop_position_bytes": 6,
            "mapping": {
                "hh_receive_channel_id": "FixedMemMap_s1a-ew-raw-s-hh-20230103t225516-20230103t225554-046625-"
                "059698-annot.dat:(172,176):scalar_uint8",
            },
            "types_mapping": {"scalar_uint8": "s_uint8"},
        }

        memmap_to_att_accessor.open(**memmap_kwargs)

    # Missing conf param primary_header_length_bytes
    with pytest.raises(MissingArgumentError):
        memmap_to_att_accessor = MemMapToAttrAccessor(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "accessor"))

        memmap_kwargs = {
            "ancillary_header_length_bytes": 0,
            "packet_length_start_position_bytes": 4,
            "packet_length_stop_position_bytes": 6,
            "mapping": {
                "hh_receive_channel_id": "FixedMemMap_s1a-ew-raw-s-hh-20230103t225516-20230103t225554-046625-"
                "059698-annot.dat:(172,176):scalar_uint8",
            },
            "types_mapping": {"scalar_uint8": "s_uint8"},
        }

        memmap_to_att_accessor.open(**memmap_kwargs)

    # Missing conf param ancillary_header_length_bytes
    with pytest.raises(MissingArgumentError):
        memmap_to_att_accessor = MemMapToAttrAccessor(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "accessor"))

        memmap_kwargs = {
            "primary_header_length_bytes": 6,
            "packet_length_start_position_bytes": 4,
            "packet_length_stop_position_bytes": 6,
            "mapping": {
                "hh_receive_channel_id": "FixedMemMap_s1a-ew-raw-s-hh-20230103t225516-20230103t225554-046625-"
                "059698-annot.dat:(172,176):scalar_uint8",
            },
            "types_mapping": {"scalar_uint8": "s_uint8"},
        }

        memmap_to_att_accessor.open(**memmap_kwargs)

    # Missing conf param packet_length_start_position_bytes
    with pytest.raises(MissingArgumentError):
        memmap_to_att_accessor = MemMapToAttrAccessor(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "accessor"))

        memmap_kwargs = {
            "primary_header_length_bytes": 6,
            "ancillary_header_length_bytes": 0,
            "packet_length_stop_position_bytes": 6,
            "mapping": {
                "hh_receive_channel_id": "FixedMemMap_s1a-ew-raw-s-hh-20230103t225516-20230103t225554-046625-"
                "059698-annot.dat:(172,176):scalar_uint8",
            },
            "types_mapping": {"scalar_uint8": "s_uint8"},
        }

        memmap_to_att_accessor.open(mode="r", **memmap_kwargs)

    # Missing conf param packet_length_stop_position_bytes
    with pytest.raises(MissingArgumentError):
        memmap_to_att_accessor = MemMapToAttrAccessor(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "accessor"))

        memmap_kwargs = {
            "primary_header_length_bytes": 6,
            "ancillary_header_length_bytes": 0,
            "packet_length_start_position_bytes": 4,
            "mapping": {
                "hh_receive_channel_id": "FixedMemMap_s1a-ew-raw-s-hh-20230103t225516-20230103t225554-046625-"
                "059698-annot.dat:(172,176):scalar_uint8",
            },
            "types_mapping": {"scalar_uint8": "s_uint8"},
        }

        memmap_to_att_accessor.open(**memmap_kwargs)

    # Missing conf param mapping
    with pytest.raises(MissingArgumentError):
        memmap_to_att_accessor = MemMapToAttrAccessor(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "accessor"))

        memmap_kwargs = {
            "primary_header_length_bytes": 6,
            "ancillary_header_length_bytes": 0,
            "packet_length_start_position_bytes": 4,
            "packet_length_stop_position_bytes": 6,
            "types_mapping": {"scalar_uint8": "s_uint8"},
        }

        memmap_to_att_accessor.open(mode="r", **memmap_kwargs)

    # Missing conf param types_mapping
    with pytest.raises(MissingArgumentError):
        memmap_to_att_accessor = MemMapToAttrAccessor(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "accessor"))

        memmap_kwargs = {
            "primary_header_length_bytes": 6,
            "ancillary_header_length_bytes": 0,
            "packet_length_start_position_bytes": 4,
            "packet_length_stop_position_bytes": 6,
            "mapping": {
                "hh_receive_channel_id": "FixedMemMap_s1a-ew-raw-s-hh-20230103t225516-20230103t225554-046625-"
                "059698-annot.dat:(172,176):scalar_uint8",
            },
        }

        memmap_to_att_accessor.open(**memmap_kwargs)

    # Missing invalid open mode w
    with pytest.raises(NotImplementedError):
        memmap_to_att_accessor = MemMapToAttrAccessor(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "accessor"))

        memmap_kwargs = {
            "primary_header_length_bytes": 6,
            "ancillary_header_length_bytes": 0,
            "packet_length_start_position_bytes": 4,
            "packet_length_stop_position_bytes": 6,
            "mapping": {
                "hh_receive_channel_id": "FixedMemMap_s1a-ew-raw-s-hh-20230103t225516-20230103t225554-046625-"
                "059698-annot.dat:(172,176):scalar_uint8",
            },
            "types_mapping": {"scalar_uint8": "s_uint8"},
        }

        memmap_to_att_accessor.open(mode="w", **memmap_kwargs)

    # Mapping is missing params, i.e. dtype
    with pytest.raises(AccessorInvalidMappingParameters):
        memmap_to_att_accessor = MemMapToAttrAccessor(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "accessor"))

        memmap_kwargs = {
            "primary_header_length_bytes": 6,
            "ancillary_header_length_bytes": 0,
            "packet_length_start_position_bytes": 4,
            "packet_length_stop_position_bytes": 6,
            "mapping": {
                "hh_receive_channel_id": "FixedMemMap_s1a-ew-raw-s-hh-20230103t225516-20230103t225554-046625-"
                "059698-annot.dat:(172,176)",
            },
            "types_mapping": {"scalar_uint8": "s_uint8"},
        }

        memmap_to_att_accessor.open(**memmap_kwargs)
        memmap_to_att_accessor.get_data("/")

    # File nothing.dat does not exist
    with pytest.raises(AccessorRetrieveError):
        memmap_to_att_accessor = MemMapToAttrAccessor(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "accessor"))

        memmap_kwargs = {
            "primary_header_length_bytes": 6,
            "ancillary_header_length_bytes": 0,
            "packet_length_start_position_bytes": 4,
            "packet_length_stop_position_bytes": 6,
            "mapping": {
                "hh_receive_channel_id": "nothing.dat:(172,176):scalar_uint8",
            },
            "types_mapping": {"scalar_uint8": "s_uint8"},
        }

        memmap_to_att_accessor.open(**memmap_kwargs)
        memmap_to_att_accessor.get_data("/")

    # Data can not be retrieved due to invalid start and stop, i.e., -1 to 0
    with pytest.raises(AccessorRetrieveError):
        memmap_to_att_accessor = MemMapToAttrAccessor(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "accessor"))

        memmap_kwargs = {
            "primary_header_length_bytes": 6,
            "ancillary_header_length_bytes": 0,
            "packet_length_start_position_bytes": 4,
            "packet_length_stop_position_bytes": 6,
            "mapping": {
                "hh_receive_channel_id": "FixedMemMap_s1a-ew-raw-s-hh-20230103t225516-20230103t225554-046625-"
                "059698-annot.dat:(-1,0):scalar_uint8",
            },
            "types_mapping": {"scalar_uint8": "s_uint8"},
        }

        memmap_to_att_accessor.open(**memmap_kwargs)
        memmap_to_att_accessor.get_data("/")


"""
MemMap tests

"""


@pytest.mark.unit
def test_memmap_strip_config():
    config = {"target_type": "uint16", "machin": "truc"}

    new_conf = MemMapAccessor.strip_config(config)

    assert len(new_conf) == 1
    assert "machin" in new_conf.keys()
    assert "target_type" not in new_conf.keys()


@pytest.mark.unit
def test_memmap_properties(EMBEDED_TEST_DATA_FOLDER_UNIT: str):
    memmap_accesssor = MemMapAccessor(
        os.path.join(
            EMBEDED_TEST_DATA_FOLDER_UNIT,
            "accessor",
            "MemMap_s1a-ew-raw-s-hh-20230103t225516-20230103t225554-046625-059698-index.dat",
        ),
        primary_header_length_bytes=6,
        ancillary_header_length_bytes=0,
        packet_length_start_position_bytes=4,
        packet_length_stop_position_bytes=6,
    )

    memmap_accesssor.set_config({"target_type": "uint16", "machin": "truc"})
    assert memmap_accesssor._target_type == "uint16"


@pytest.mark.unit
def test_memmap_error_cases(EMBEDED_TEST_DATA_FOLDER_UNIT: str):
    # File not found
    with pytest.raises(IOError):
        memmap_accessor = MemMapAccessor(
            os.path.join(
                EMBEDED_TEST_DATA_FOLDER_UNIT,
                "accessor",
                "Machinbidule.dat",
            ),
            primary_header_length_bytes=6,
            ancillary_header_length_bytes=0,
            packet_length_start_position_bytes=4,
            packet_length_stop_position_bytes=6,
        )
        memmap_accessor.open(target_type="uint16")
    # Missing conf param
    with pytest.raises(MissingArgumentError):
        memmap_accessor = MemMapAccessor(
            os.path.join(
                EMBEDED_TEST_DATA_FOLDER_UNIT,
                "accessor",
                "Machinbidule.dat",
            ),
            primary_header_length_bytes=6,
            packet_length_start_position_bytes=4,
            packet_length_stop_position_bytes=6,
        )
    # Missing type param
    with pytest.raises(MissingArgumentError):
        memmap_accessor = MemMapAccessor(
            os.path.join(
                EMBEDED_TEST_DATA_FOLDER_UNIT,
                "accessor",
                "Machinbidule.dat",
            ),
            primary_header_length_bytes=6,
            ancillary_header_length_bytes=0,
            packet_length_start_position_bytes=4,
            packet_length_stop_position_bytes=6,
        )
        memmap_accessor.open()
    # not an attr accessor
    with pytest.raises(NotImplementedError):
        memmap_accessor = MemMapAccessor(
            os.path.join(
                EMBEDED_TEST_DATA_FOLDER_UNIT,
                "accessor",
                "Machinbidule.dat",
            ),
            primary_header_length_bytes=6,
            ancillary_header_length_bytes=0,
            packet_length_start_position_bytes=4,
            packet_length_stop_position_bytes=6,
        )
        memmap_accessor.write_attrs("", dict())


@pytest.mark.unit
def test_memmap_write_uint16(OUTPUT_DIR):
    memmap_accesssor = MemMapAccessor(
        os.path.join(
            OUTPUT_DIR,
            "test_memmap.dat",
        ),
        primary_header_length_bytes=6,
        ancillary_header_length_bytes=0,
        packet_length_start_position_bytes=4,
        packet_length_stop_position_bytes=6,
    )
    memmap_accesssor.open(mode="w", target_type="uint16")
    memmap_accesssor._reconversion_attrs = numpy.asarray([32, 32, 32, 32, 32], dtype=numpy.uint8)
    param = numpy.zeros((len(memmap_accesssor._reconversion_attrs),), dtype="B")
    memmap_accesssor.write_data("(0,16,16)", param)


@pytest.mark.unit
def test_memmap_open_uint16(EMBEDED_TEST_DATA_FOLDER_UNIT: str):
    memmap_accesssor = MemMapAccessor(
        os.path.join(
            EMBEDED_TEST_DATA_FOLDER_UNIT,
            "accessor",
            "MemMap_s1a-ew-raw-s-hh-20230103t225516-20230103t225554-046625-059698-index.dat",
        ),
        primary_header_length_bytes=6,
        ancillary_header_length_bytes=0,
        packet_length_start_position_bytes=4,
        packet_length_stop_position_bytes=6,
    )

    memmap_accesssor.open(target_type="uint16")
    # open again
    memmap_accesssor.open(target_type="uint16")
    numpy_array = memmap_accesssor.get_data("(352,368,16)").compute()
    assert numpy_array[0] == 16355
    assert numpy_array.shape[0] == 2
    memmap_accesssor.close()


@pytest.mark.unit
@pytest.mark.real_s3
def test_memmap_open_uint16_s3(dask_context_processes, s3_test_data, s3_config_real):
    memmap_accesssor = MemMapAccessor(
        AnyPath(
            f"{s3_test_data[0]}://{s3_test_data[1]}"
            f"/embedbed/MemMap_s1a-ew-raw-s-hh-20230103t225516-20230103t225554-046625-059698-index.dat",
            **dict(s3_config_real),
        ),
        primary_header_length_bytes=6,
        ancillary_header_length_bytes=0,
        packet_length_start_position_bytes=4,
        packet_length_stop_position_bytes=6,
    )

    memmap_accesssor.open(target_type="uint16")
    # open again
    memmap_accesssor.open(target_type="uint16")
    numpy_array = memmap_accesssor.get_data("(352,368,16)").compute()
    print(numpy_array)
    assert numpy_array[0] == 16355
    assert numpy_array.shape[0] == 2
    memmap_accesssor.close()


# TODO investigate why the packets length are not consistent with the file
"""
@pytest.mark.skip(reason="not working well, packet length are inconsistent")
@pytest.mark.unit
def test_memmap_open_var_bytearray(EMBEDED_TEST_DATA_FOLDER_UNIT: str):
    memmap_accesssor = MemMapAccessor(
        os.path.join(
            EMBEDED_TEST_DATA_FOLDER_UNIT,
            "MemMap_s1a-ew-raw-s-hv-20230103t225516-20230103t225554-046625-059698-index.dat",
        ),
        primary_header_length=6,
        ancillary_header_length=0,
        packet_length_start_position=4,
        packet_length_stop_position=6,
    )

    memmap_accesssor.open(target_type="var_bytearray")
    numpy_array = memmap_accesssor[544:None:-1].compute()
    assert numpy_array.shape[1] == 6
    assert numpy_array.shape[0] == 2
    assert numpy.allclose(numpy_array[0], [0, 0, 30, 170, 0, 0, 67, 251, 0, 3, 190, 187, 30, 170, 1, 83, 17, 122])
    memmap_accesssor.close()

"""


@pytest.mark.unit
def test_memmap_open_bytearray(EMBEDED_TEST_DATA_FOLDER_UNIT: str):
    memmap_accesssor = MemMapAccessor(
        os.path.join(
            EMBEDED_TEST_DATA_FOLDER_UNIT,
            "accessor",
            "MemMap_s1a-ew-raw-s-hh-20230103t225516-20230103t225554-046625-059698-index.dat",
        ),
        primary_header_length_bytes=6,
        ancillary_header_length_bytes=0,
        packet_length_start_position_bytes=4,
        packet_length_stop_position_bytes=6,
    )

    memmap_accesssor.open(target_type="bytearray")
    numpy_array = memmap_accesssor.get_data("(472,520,48)").compute()
    assert numpy_array.shape[1] == 6
    assert numpy_array.shape[0] == 2
    assert numpy.allclose(numpy_array[0], [101, 0, 0, 0, 0, 0])
    memmap_accesssor.close()


"""
S2 Mem Map Tests

"""


@pytest.mark.unit
def test_s2memmap_strip_config():
    config = {"target_type": "uint16", "machin": "truc"}

    new_conf = MultipleFilesMemMapAccessor.strip_config(config)

    assert len(new_conf) == 1
    assert "machin" in new_conf.keys()
    assert "target_type" not in new_conf.keys()


@pytest.mark.unit
def test_s2memmap_properties(EMBEDED_TEST_DATA_FOLDER_UNIT: str):
    memmap_accesssor = MultipleFilesMemMapAccessor(
        os.path.join(
            EMBEDED_TEST_DATA_FOLDER_UNIT,
            "accessor",
            "MemMap_s1a-ew-raw-s-hh-20230103t225516-20230103t225554-046625-059698-index.dat",
        ),
        primary_header_length_bytes=6,
        ancillary_header_length_bytes=0,
        packet_length_start_position_bytes=4,
        packet_length_stop_position_bytes=6,
    )

    memmap_accesssor.set_config({"target_type": "uint16", "machin": "truc"})
    assert memmap_accesssor._target_type == "uint16"


@pytest.mark.unit
def test_s2memmap_error_cases(EMBEDED_TEST_DATA_FOLDER_UNIT: str):
    # File not found
    with pytest.raises(FileNotFoundError):
        memmap_accessor = MultipleFilesMemMapAccessor(
            os.path.join(
                EMBEDED_TEST_DATA_FOLDER_UNIT,
                "accessor",
                "Machinbidule.dat",
            ),
            primary_header_length_bytes=6,
            ancillary_header_length_bytes=0,
            packet_length_start_position_bytes=4,
            packet_length_stop_position_bytes=6,
        )
        memmap_accessor.open(target_type="uint16")
    # Missing conf param
    with pytest.raises(MissingArgumentError):
        memmap_accessor = MultipleFilesMemMapAccessor(
            os.path.join(
                EMBEDED_TEST_DATA_FOLDER_UNIT,
                "accessor",
                "Machinbidule.dat",
            ),
            primary_header_length_bytes=6,
            packet_length_start_position_bytes=4,
            packet_length_stop_position_bytes=6,
        )
    # Missing type param
    with pytest.raises(MissingArgumentError):
        memmap_accessor = MultipleFilesMemMapAccessor(
            os.path.join(
                EMBEDED_TEST_DATA_FOLDER_UNIT,
                "accessor",
                "Machinbidule.dat",
            ),
            primary_header_length_bytes=6,
            ancillary_header_length_bytes=0,
            packet_length_start_position_bytes=4,
            packet_length_stop_position_bytes=6,
        )
        memmap_accessor.open()
    # not an attr accessor
    with pytest.raises(NotImplementedError):
        memmap_accessor = MultipleFilesMemMapAccessor(
            os.path.join(
                EMBEDED_TEST_DATA_FOLDER_UNIT,
                "accessor",
                "Machinbidule.dat",
            ),
            primary_header_length_bytes=6,
            ancillary_header_length_bytes=0,
            packet_length_start_position_bytes=4,
            packet_length_stop_position_bytes=6,
        )
        memmap_accessor.write_attrs("", dict())


@pytest.mark.unit
def test_s2memmap_open_uint16(EMBEDED_TEST_DATA_FOLDER_UNIT: str):
    original_cache_size = EOConfiguration().get("accessors__memmap__packet_cache_size")
    EOConfiguration().load_dict({"accessors__memmap__packet_cache_size": 10})

    memmap_accesssor = MultipleFilesMemMapAccessor(
        os.path.join(
            EMBEDED_TEST_DATA_FOLDER_UNIT,
            "accessor",
            "S2MemMap_S2B_OPER_MSI_L0__GR_2BPS_20221223T230531_S20221223T220352_D01_B01.bin",
        ),
        primary_header_length_bytes=6,
        ancillary_header_length_bytes=20,
        packet_length_start_position_bytes=10,
        packet_length_stop_position_bytes=12,
    )

    memmap_accesssor.open(target_type="uint16")
    dask_array = memmap_accesssor.get_data("178,192,14")
    print(dask_array)
    numpy_array = dask_array.compute()
    print(numpy_array)
    # packet sequence count is from 0 to nb_packets
    assert numpy_array[0] == 0
    assert numpy_array[23] == 23
    assert numpy_array.shape[0] == 24
    memmap_accesssor.close()

    EOConfiguration().load_dict({"accessors__memmap__packet_cache_size": original_cache_size})


@pytest.mark.unit
def test_s2memmap_open_var_bytearray(EMBEDED_TEST_DATA_FOLDER_UNIT: str):
    memmap_accesssor = MultipleFilesMemMapAccessor(
        os.path.join(
            EMBEDED_TEST_DATA_FOLDER_UNIT,
            "accessor",
            "S2MemMap_S2B_OPER_MSI_L0__GR_2BPS_20221223T230531_S20221223T220352_D01_B01.bin",
        ),
        primary_header_length_bytes=6,
        ancillary_header_length_bytes=20,
        packet_length_start_position_bytes=10,
        packet_length_stop_position_bytes=12,
    )

    memmap_accesssor.open(target_type="var_bytearray")
    numpy_array = memmap_accesssor.get_data("544,None,-1").compute()
    assert numpy_array.shape[1] == 11784
    assert numpy_array.shape[0] == 24
    # testing the first 18 elements only
    assert numpy.allclose(numpy_array[0][:18], [113, 0, 134, 0, 0, 0, 197, 0, 102, 54, 105, 0, 113, 0, 134, 0, 0, 0])
    memmap_accesssor.close()


@pytest.mark.unit
def test_s2memmap_open_bytearray(EMBEDED_TEST_DATA_FOLDER_UNIT: str):
    memmap_accesssor = MultipleFilesMemMapAccessor(
        os.path.join(
            EMBEDED_TEST_DATA_FOLDER_UNIT,
            "accessor",
            "S2MemMap_S2B_OPER_MSI_L0__GR_2BPS_20221223T230531_S20221223T220352_D01_B01.bin",
        ),
        primary_header_length_bytes=6,
        ancillary_header_length_bytes=20,
        packet_length_start_position_bytes=10,
        packet_length_stop_position_bytes=12,
    )

    memmap_accesssor.open(target_type="bytearray")
    numpy_array = memmap_accesssor.get_data("472,520,48").compute()
    assert numpy_array.shape[1] == 6
    assert numpy_array.shape[0] == 24
    assert numpy.allclose(numpy_array[0], [0, 0, 0, 197, 0, 102])
    memmap_accesssor.close()


@pytest.mark.unit
def test_s2memmap_open_scalar_uint16(EMBEDED_TEST_DATA_FOLDER_UNIT: str):
    memmap_accesssor = MultipleFilesMemMapAccessor(
        os.path.join(
            EMBEDED_TEST_DATA_FOLDER_UNIT,
            "accessor",
            "S2MemMap_S2B_OPER_MSI_L0__GR_2BPS_20221223T230531_S20221223T220352_D01_B01.bin",
        ),
        primary_header_length_bytes=6,
        ancillary_header_length_bytes=20,
        packet_length_start_position_bytes=10,
        packet_length_stop_position_bytes=12,
    )

    memmap_accesssor.open(target_type="s_uint16")
    numpy_array = memmap_accesssor.get_data("178,192,14").compute()
    # packet sequence count is from 0 to nb_packets
    assert numpy_array[0] == 0
    assert numpy_array.shape[0] == 1
    memmap_accesssor.close()


@pytest.mark.unit
def test_s2memmap_write_uint16(OUTPUT_DIR):
    memmap_accesssor = MultipleFilesMemMapAccessor(
        os.path.join(
            OUTPUT_DIR,
            "test_memmap.dat",
        ),
        primary_header_length_bytes=6,
        ancillary_header_length_bytes=20,
        packet_length_start_position_bytes=10,
        packet_length_stop_position_bytes=12,
    )
    memmap_accesssor.open(mode="w", target_type="uint16")
    memmap_accesssor._reconversion_attrs = numpy.asarray([32, 32, 32, 32, 32], dtype=numpy.uint8)
    param = numpy.zeros((len(memmap_accesssor._reconversion_attrs),), dtype="B")
    memmap_accesssor.write_data("0,16,16", param)
