import netCDF4

# OPeNDAP.
url = 'http://omgsrv1.meas.ncsu.edu:8080/thredds/dodsC/fmrc/sabgom/SABGOM_Forecast_Model_Run_Collection_best.ncd'
nc = netCDF4.Dataset(url)

# Compiled with cython.
assert nc.filepath() == url
