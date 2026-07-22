import os
from pathlib import Path

import pytest

pytestmark = pytest.mark.dask_only
dask = pytest.importorskip("dask")
pytest.importorskip("distributed")

from eopf.accessor.memmap_accessors import MemMapAccessor
from eopf.store.safe_reader import EODataTreeSafeReader


@pytest.mark.unit
def test_memmap_open_uint16_isp_873(EMBEDED_TEST_DATA_FOLDER_UNIT: str):
    memmap_accesssor = MemMapAccessor(
        os.path.join(
            EMBEDED_TEST_DATA_FOLDER_UNIT,
            "from_user",
            "isp_mwr_bad_873",
            "ISPData.dat",
        ),
        primary_header_length_bytes=6,
        ancillary_header_length_bytes=0,
        packet_length_start_position_bytes=4,
        packet_length_stop_position_bytes=6,
    )

    memmap_accesssor.open(target_type="var_bytearray")
    # open again
    numpy_array = memmap_accesssor.get_data("(0,None,-1)").data.compute()
    print(numpy_array)
    memmap_accesssor.close()


@pytest.mark.unit
def test_safe_load(EMBEDED_TEST_DATA_FOLDER_UNIT: Path):
    product = EODataTreeSafeReader().open_datatree(
        filename_or_obj=EMBEDED_TEST_DATA_FOLDER_UNIT / "from_user" / "isp_mwr_bad_873" / "S3A_MW_0_MWR____20200121T043455_20200121T061705_20241211T084714_6129_054_076______LN3_O_NR_002.SEN3",

    )
    assert product is not None
    numpy_array = product["/measurements/isp"].data.compute()
    assert numpy_array.shape == (40097, 58)
    print(numpy_array)
