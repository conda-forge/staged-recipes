'''
   Drivers that do not fit the driverCore format.
'''

import pandas as pd
import requests
import json
from copy import deepcopy
import pyperclip
import math
import re
import inspect
import yaml
import itertools
import warnings

from datetime import datetime
from datapungi_fed import generalSettings  # NOTE: projectName
#import generalSettings        #NOTE: projectName
from datapungi_fed import utils  # NOTE: projectName
#import utils                  #NOTE: projectName
from datapungi_fed.driverCore import driverCore
#from driverCore import driverCore


class datasetlist(driverCore):
    def _query(self):
        '''
         Returns name of available datasets, a short description and their query parameters.
         Args:
           none
         Output:
           - pandas table with query function name, database name, short description and query parameters.
        '''
        #get all dictionary of all drivers (in config/datasetlist.yaml)
        datasetlist = self._dbParams
        datasetlistExp = [[{**entry, **dataset}
                           for dataset in entry.pop('datasets')] for entry in datasetlist]
        datasetlistFlat = list(itertools.chain.from_iterable(
            datasetlistExp))  # flatten the array of array
        df_output = pd.DataFrame(datasetlistFlat)
        return(df_output)
    def __call__(self):
        return(self._query())
    

if __name__ == '__main__':
    d = datasetlist()
    v = d(); print(v)