
#!/usr/bin/env python3

import nctoolkit as nc
import pandas

def test_min():
    data = nc.open_data("dummy.nc")

    assert "sst" in data.variables
