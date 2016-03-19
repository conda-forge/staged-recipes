import fiona

fname = 'test.shp'

with fiona.open(fname, 'r') as f:
    assert f.schema['geometry'] == 'Point'
