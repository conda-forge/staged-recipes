"""Gets FRED and GeoFRED data from Federal Reserve (FED) by connecting to its API."""
import pandas
import requests
import sys

from datapungi_fed.api import *
import datapungi_fed.tests as tests

__version__ = '0.3.1'


class topCall(sys.modules[__name__].__class__):
    def __call__(self,*args,**kwargs):
        coreClass = data()
        return(coreClass(*args,**kwargs))
    def __str__(self):
        starter = "\nSample starter: \n\nimport datapungi_fed as dpf \n\ndata = dpf.data() \nprint(data) \npor just query a time series: \ndpf('gdp')"
        return(starter)

sys.modules[__name__].__class__ = topCall