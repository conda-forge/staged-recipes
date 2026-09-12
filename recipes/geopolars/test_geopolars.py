"""Exercise the compiled geo kernels through the Python API."""

import polars as pl

import geopolars
from geopolars import GeoDataFrame, GeoSeries

df = geopolars.datasets.read_dataset("naturalearth_lowres")
assert isinstance(df, GeoDataFrame), type(df)
assert df.shape == (177, 6), df.shape

geometry = df.get_column("geometry")
assert isinstance(geometry, GeoSeries), type(geometry)

# Properties backed by the Rust extension module.
assert isinstance(geometry.area, pl.Series)
assert geometry.area.len() == 177
assert geometry.area.min() > 0

assert isinstance(geometry.centroid, GeoSeries)
assert isinstance(geometry.geom_type, pl.Series)

# Methods backed by the Rust extension module.
assert isinstance(geometry.convex_hull(), GeoSeries)
assert isinstance(geometry.envelope(), GeoSeries)
assert isinstance(geometry.euclidean_length(), pl.Series)
assert isinstance(geometry.translate(1.0, 2.0), GeoSeries)
assert isinstance(geometry.rotate(90.0), GeoSeries)

print("geopolars", geopolars.__version__, "OK against polars", pl.__version__)
