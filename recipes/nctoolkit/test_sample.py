import nctoolkit as nc

def test_min():
    data = nc.open_data("dummy.nc")

    assert "sst" in data.variables
