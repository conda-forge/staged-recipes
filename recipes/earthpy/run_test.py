import earthpy.io as eio
import rasterio as rio

with rio.open(eio.path_to_example('rmnp-dem.tif')) as src:
    dem = src.read()
