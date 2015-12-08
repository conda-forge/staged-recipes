import netCDF4

# OPeNDAP.
url = 'http://test.opendap.org:80/opendap/data/ncml/sample_virtual_dataset.ncml'
nc = netCDF4.Dataset(url)

# Compiled with cython.
assert nc.filepath() == url
