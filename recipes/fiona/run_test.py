import os
import fiona

fname = os.path.join(os.environ['RECIPE_DIR'], 'test_data', 'test.shp')

with fiona.open(fname, 'r') as f:
    assert f.schema['geometry'] == 'Point'

# https://github.com/conda-forge/fiona-feedstock/issues/49
meta = {'driver': 'ESRI Shapefile', 'schema': {'geometry': 'Point', 'properties': {'RETURN_P': 'int'}}}
dst = fiona.open('new.shp', 'w', **meta)
g = {'coordinates': [1.0, 2.0], 'type': 'Point'}
feature = {'geometry': g, 'properties': {'RETURN_P': None}}
dst.write(feature)
dst.close()

src = fiona.open('new.shp', 'r')
feature = next(src)
assert(feature['properties']['RETURN_P'] is None)  # Fails
src.close()
