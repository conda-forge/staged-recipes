"""Testing ancillary functions."""
from typing import Any

import geopandas as gpd
import numpy as np
import numpy.typing as npt
import pandas as pd
import pytest
import xarray as xr
from pyproj.crs import CRS
from pyproj.exceptions import CRSError

from gdptools.ancillary import _check_for_intersection
from gdptools.ancillary import _generate_weights_pershp
from gdptools.ancillary import _get_cells_poly
from gdptools.ancillary import _get_crs
from gdptools.ancillary import _get_data_via_catalog
from gdptools.ancillary import _get_shp_file
from gdptools.gdp_data_class import CatGrids
from gdptools.gdp_data_class import CatParams


@pytest.mark.parametrize(
    "crs",
    [
        "epsg:4326",
        4326,
        "+proj=longlat +a=6378137 +f=0.00335281066474748 +pm=0 +no_defs",
    ],
)
def test__get_crs(crs: Any) -> None:
    """Test the get_crs function."""
    crs = _get_crs(crs)
    assert isinstance(crs, CRS)


@pytest.mark.parametrize(
    "crs",
    [
        "espg:4326",
        43,
        "+a=6378137 +f=0.00335281066474748 +pm=0 +no_defs",
    ],
)
def test__get_bad_crs(crs: Any) -> None:
    """Test the get_crs function."""
    with pytest.raises(CRSError):
        crs = _get_crs(crs)


@pytest.fixture
def param_json() -> pd.DataFrame:
    """Return parameter json."""
    param_json = "https://mikejohnson51.github.io/opendap.catalog/cat_params.json"
    params = pd.read_json(param_json)
    _id = "gridmet"  # noqa
    _varname = "daily_maximum_temperature"  # noqa
    return params.query("id == @_id & varname == @_varname")


@pytest.fixture
def grid_json() -> pd.DataFrame:
    """Return grid json."""
    grid_json = "https://mikejohnson51.github.io/opendap.catalog/cat_grids.json"
    grids = pd.read_json(grid_json)
    _gridid = 176  # noqa
    return grids.query("grid_id == @_gridid")


@pytest.fixture
def gdf() -> gpd.GeoDataFrame:
    """Create xarray dataset."""
    return gpd.read_file("./tests/data/hru_1210.shp")


@pytest.fixture
def catparam(param_json) -> CatParams:
    """Return CatParams."""
    return CatParams(**param_json.to_dict("records")[0])


@pytest.fixture
def catgrid(grid_json) -> CatGrids:
    """Return CatGrids."""
    return CatGrids(**grid_json.to_dict("records")[0])


@pytest.fixture
def is_degrees(gdf, catparam, catgrid) -> bool:
    is_intersect, is_degrees, is_0_360 = _check_for_intersection(
        params_json=catparam, grid_json=catgrid, gdf=gdf
    )
    return is_degrees


@pytest.fixture
def bounds(gdf, catgrid, is_degrees) -> npt.NDArray[np.double]:
    """Get bounds."""
    gdf, bounds = _get_shp_file(gdf, catgrid, is_degrees)
    return bounds


@pytest.fixture
def xarray(catparam, catgrid, bounds) -> xr.Dataset:
    """Create xarray dataset."""
    return _get_data_via_catalog(catparam, catgrid, bounds, "2020-01-01")


def test__get_cells_poly(catparam, catgrid, bounds) -> None:
    """Test _get_cells_poly."""
    ds = _get_data_via_catalog(catparam, catgrid, bounds, "2020-01-01")
    assert isinstance(ds, xr.DataArray)
    gdf = _get_cells_poly(
        xr_a=ds, x=catgrid.X_name, y=catgrid.Y_name, var=catparam.varname, crs_in=4326
    )
    assert isinstance(gdf, gpd.GeoDataFrame)


def test__generate_weights_pershape(gdf, catparam, catgrid, bounds) -> None:
    """Test _generate_weights_pershape."""
    ds = _get_data_via_catalog(catparam, catgrid, bounds, "2020-01-01")
    assert isinstance(ds, xr.DataArray)
    grid_cells = _get_cells_poly(
        xr_a=ds,
        x=catgrid.X_name,
        y=catgrid.Y_name,
        var=catparam.varname,
        crs_in=catgrid.proj,
    )
    assert isinstance(grid_cells, gpd.GeoDataFrame)
    df = _generate_weights_pershp(
        poly=gdf,
        poly_idx="hru_id_nat",
        grid_cells=grid_cells,
        grid_cells_crs=catgrid.proj,
        wght_gen_crs=6931,
    )
    assert isinstance(df, pd.DataFrame)
