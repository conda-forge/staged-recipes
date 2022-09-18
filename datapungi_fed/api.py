import pandas as pd
import requests
import sys
from datapungi_fed import generalSettings 
from datapungi_fed import drivers
from datapungi_fed.driverCore import driverCore
#from driverCore import driverCore
#import drivers

#TODO: test clipcode, utils (setting folder, options), getting help in each step.
class data():
    '''
       Connect to all of FRED and GeoFred databases. To start, choose a database group from:

       - categories: 8 top categories (eg, National Accounts) and their subgroups
                   https://fred.stlouisfed.org/categories/
       - releases: about 300 datasets of time series grouped by release (eg, Penn World Table)
                   https://fred.stlouisfed.org/releases/
       - series: time series data
                   https://fred.stlouisfed.org/
       - sources: about 90 data providers (eg, IMF and Bank of Mexico)
                   https://fred.stlouisfed.org/sources/
       - tags: 	Tags applied to time series (eg, location, data source, frequency) - about 5,000 tags
                   https://fred.stlouisfed.org/tags/
       - geo: spatial economic data
                   https://geofred.stlouisfed.org/

       For example:
       import datapungi_fed as dpf

       data = dpf.data()
       print(data.series)

       This class, and datapungi_fed itself, defaults to the series database.  Hence, the following
       will query the series database:

       import datapungi_fed as dpf

       dfp('gdp')
       data = dpf.data()
       data('gdp')

       Check the __doc__ of each database for more information.
    '''
    def __init__(self,connectionParameters = {}, userSettings = {}):
        self.__connectInfo = generalSettings.getGeneralSettings(connectionParameters = connectionParameters, userSettings = userSettings ) 
        self._metadata = self.__connectInfo.packageMetadata
        self._help     = self.__connectInfo.datasourceOverview
        #load drivers:
        loadInfo = {'baseRequest' : self.__connectInfo.baseRequest, 'connectionParameters' : self.__connectInfo.connectionParameters}
        
        #specific drivers
        self.datasetlist  = drivers.datasetlist(**loadInfo)
        
        #core drivers
        coreDriversParams = driverCore()
        for dbGroupName in [x['group'] for x in coreDriversParams._dbParams]:
            setattr(self, dbGroupName.lower(), driverCore(dbGroupName,**loadInfo))
             
    def __call__(self,*args,**kwargs):
        return(self.series(*args,**kwargs))

    def __str__(self):
        return(self.__doc__)

    def _clipcode(self):
        try:
            self._lastCalledDriver.clipcode()
        except:
            print('Get data using a driver first, eg: ')
            #eg: data.NIPA("T10101", verbose = True)
    

if __name__ == '__main__':            
    d = data()
    #print(d)
    #print(d.datasetlist())   
    #print(d.categories(125))   
    #print(d.releases())   
    #print(d.series('GDP'))
    #print(d('GNP'))
    #print(d.sources('1'))   
    #print(d.tags(tag_names='monetary+aggregates;weekly'))   
    #print(d.geo['shapes']('bea'))
    #print(d.geo['meta']('SMU56000000500000001a'))
    #v= d.geo['series'](series_id='WIPCPI',start_date='2012-01-01',verbose=True)
    #print(v)

    #v= d.geo['data'](series_group='882',date='2013-01-01',region_type='state',units='Dollars',frequency='a',season='NSA')
    #print(v)
    #print(d.geo(series_id='WIPCPI',start_date='2012-01-01'))
    #print(d.geo.__doc__)
    d.categories(125)