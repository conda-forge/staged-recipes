from xbitinfo.bitround import jl_bitround, xr_bitround
from xbitinfo.graphics import plot_bitinformation, plot_distribution
from xbitinfo.xbitinfo import get_bitinformation, get_keepbits, get_prefect_flow

import xarray as xr
import xbitinfo as xb

ds = xr.tutorial.load_dataset("air_temperature")
bitinfo = xb.get_bitinformation(ds, dim="lon")  # calling bitinformation.jl.bitinformation
keepbits = xb.get_keepbits(bitinfo, inflevel=0.99)  # get number of mantissa bits to keep for 99% real information
ds_bitrounded = xb.xr_bitround(ds, keepbits)  # bitrounding keeping only keepbits mantissa bits