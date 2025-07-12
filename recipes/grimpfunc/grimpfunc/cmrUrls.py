#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar 19 15:37:45 2021

@author: ian
"""
import param
import numpy as np
from datetime import datetime
import pandas as pd
import grimpfunc as grimp
import panel as pn

modes = {'none': {'productIndexes': [0, 1, 2, 3, 4, 5, 6, 7],
                  'boxNames': False, 'cumulative': True,
                  'defaultProduct': 'NSIDC-0725'},

         'subsetter': {'productIndexes': [1, 2, 3, 4, 5, 6, 7],
                       'boxNames': True, 'cumulative': False,
                       'defaultProduct': 'NSIDC-0725'},
         'nisar': {'productIndexes': [2, 3, 4, 5],
                   'boxNames': False, 'cumulative': False,
                   'defaultProduct': 'NSIDC-0725'},
         'image': {'productIndexes': [1],
                   'boxNames': False, 'cumulative': False,
                   'defaultProduct': 'NSIDC-0723'},
         'terminus': {'productIndexes': [0],
                      'boxNames': False, 'cumulative': False,
                      'defaultProduct': 'NSIDC-0642'}
         }

products = ['NSIDC-0642',
            'NSIDC-0723',
            'NSIDC-0725', 'NSIDC-0727', 'NSIDC-0731', 'NSIDC-0766',
            'NSIDC-0481', 'NSIDC-0646']

velocityMosaics = ['NSIDC-0725', 'NSIDC-0727', 'NSIDC-0731', 'NSIDC-0766']

velocityOptions = ['browse', 'speed', 'velocity', 'velocity+errors', 'all']

productOptions = {'NSIDC-0642': ['termini'],
                  'NSIDC-0723': ['image', 'gamma0', 'sigma0'],
                  'NSIDC-0725': velocityOptions,
                  'NSIDC-0727': velocityOptions,
                  'NSIDC-0731': velocityOptions,
                  'NSIDC-0766': velocityOptions,
                  'NSIDC-0481': velocityOptions[1:],
                  'NSIDC-0646': velocityOptions[1:]
                  }
# Current versions, if versions updated at DAAC, will try later version
versions = {'NSIDC-0723': '4', 'NSIDC-0725': '5', 'NSIDC-0727': '5',
            'NSIDC-0731': '5', 'NSIDC-0642': '2', 'NSIDC-0766': '2',
            'NSIDC-0481': '3', 'NSIDC-0646': '3'
            }
defaultProduct = 'NSIDC-0725'

productGroups = {'browse': ['browse'],
                 'speed': ['vv'], '-': ['vv'], 'vx': 'vx',
                 'velocity': ['vv', 'vx', 'vy'],
                 'velocity+errors': ['vv', 'vx', 'vy', 'ex', 'ey'],
                 'all': ['vv', 'vx', 'vy', 'ex', 'ey', 'browse', 'dT'],
                 'sigma0': ['sigma0'],
                 'gamma0': ['gamma0'],
                 'image':  ['image'],
                 'termini': ['termini']
                 }
fileTypes = dict.fromkeys(productGroups.keys(), ['.tif'])  # Set all to tif
fileTypes['termini'] = ['.shp']  # shp

defaultBounds = {'LatMin': 60, 'LatMax': 82, 'LonMin': -75, 'LonMax': -5}


class cmrUrls(param.Parameterized):
    '''Class to allow user to select product params and then search for
    matching data'''

    # product Information
    # Select Product
    product = param.ObjectSelector(defaultProduct, objects=products)
    productFilter = param.ObjectSelector(
        productOptions[defaultProduct][0],
        objects=productOptions[defaultProduct])
    # Date range for search
    firstDate = param.CalendarDate(default=datetime(2000, 1, 1).date())
    lastDate = param.CalendarDate(default=datetime.today().date())

    LatMin = pn.widgets.FloatSlider(name='Lat min', disabled=True,
                                    value=defaultBounds['LatMin'],
                                    start=defaultBounds['LatMin'],
                                    end=defaultBounds['LatMax'])
    LatMax = pn.widgets.FloatSlider(name='Lat max', disabled=True,
                                    value=defaultBounds['LatMax'],
                                    start=defaultBounds['LatMin'] + 1,
                                    end=defaultBounds['LatMax'])
    LonMin = pn.widgets.FloatSlider(name='Lon min', disabled=True,
                                    value=defaultBounds['LonMin'],
                                    start=defaultBounds['LonMin'],
                                    end=defaultBounds['LonMax'])
    LonMax = pn.widgets.FloatSlider(name='Lon max', disabled=True,
                                    value=defaultBounds['LonMax'],
                                    start=defaultBounds['LonMin'] + 1,
                                    end=defaultBounds['LonMax'])
    #
    Search = param.Boolean(False)
    Clear = param.Boolean(False)
    results = pd.DataFrame()

    def __init__(self, mode='none', debug=False, date1=None, date2=None,
                 verbose=False):
        super().__init__()
        #
        self.mode = mode.lower()
        #
        self.param.set_param('product', modes[self.mode]['defaultProduct'])
        self.setProductOptions()
        #
        self.validProducts = \
            [products[x] for x in modes[self.mode]['productIndexes']]
        self.param.set_param('product',
                             products[modes[self.mode]['productIndexes'][0]])

        self.verbose = verbose
        #
        # Pick only 1 481 product by box name
        if modes[self.mode]['boxNames']:
            if modes[self.mode]['boxNames']:
                productOptions['NSIDC-0481'] = self.TSXBoxNames()
                productOptions['NSIDC-0646'] = self.TSXBoxNames(product=
                                                                'NSIDC-0646')
            for x in productOptions['NSIDC-0481']:
                productGroups[x] = ['vv']
                fileTypes[x] = ['.tif']
            for x in productOptions['NSIDC-0646']:
                productGroups[x] = ['vx']
                fileTypes[x] = ['.tif']
        # Subsetter modes only one option
        if not modes[self.mode]['cumulative']:
            self.param.Clear.precedence = -1
            for prod in velocityMosaics:
                productOptions[prod] = ['-']
        # Get mode appropriate objects
        self.param.product.objects = \
            [self.param.product.objects[x]
             for x in modes[self.mode]['productIndexes']]
        #
        
        # Init variables
        self.first = True
        self.cogs = []
        self.urls = []
        self.nUrls = 0
        self.productList = []
        self.nProducts = 0
        self.newProductCount = 0
        self.dates = []
        self.debug = debug
        self.msg = 'Init'
    # initialize with empty list

    def getCogs(self, replace=None, removeTiff=False):
        cogs  = [x for x in self.urls if x.endswith('.tif')]
        if removeTiff:
            cogs  = [x.replace('.tif', '') for x in cogs]
        if replace is not None:
            cogs  = [x.replace(replace, '*') for x in cogs]
        return cogs

    def getShapes(self):
        return [x for x in self.urls if x.endswith('.shp')]

    def checkIDs(self, testIDs):
        ''' Check if 1 or more of the ids in testIDs is in the current IDs'''
        for id in self.getIDs():  # Check each id type
            if id in testIDs:
                return True  # Return if found
        return False  # None present

    def getIDs(self):
        ''' Get the unique list of ids from the cog and shape files'''
        files = self.getCogs() + self.getShapes()
        fileIDs = [x.split('/')[-3].split('.')[0] for x in files]  # Find ids
        return np.unique(fileIDs)  # Return the unique ids

    @param.depends('Clear', watch=True)
    def clearData(self):
        self.resetData()
        self.Clear = False

    def resetData(self):
        self.products = []
        self.urls = []
        self.nUrls = 0
        self.nProducts = 0
        self.newProductCount = 0
        self.dates = []
        self.productList = []
        self.results = pd.DataFrame(zip(self.dates, self.productList),
                                    columns=['date', 'product'])

    @param.depends('Search', watch=True)
    def findData(self, initSearch=False):
        '''Search NASA/NSIDC Catalog for dashboard parameters'''
        # Return if not a button push (e.g., first)
        if not self.Search and not initSearch:
            return
        # Start fresh for each search if not cumulative
        if not modes[self.mode]['cumulative']:
            self.resetData()
        #
        newUrls = self.getURLS()
        self.msg = len(newUrls)
        # append list. Use unique to avoid selecting same data set
        self.urls = list(np.unique(newUrls + self.urls))
        self.nUrls = len(self.urls)
        self.updateProducts(newUrls)
        self.results = pd.DataFrame(zip(self.dates, self.productList),
                                    columns=['date', 'product'])
        # reset get Data
        self.Search = False

    def updateProducts(self, newUrls):
        ''' Generate a list of the products in the url list'''
        fileType = productGroups[self.productFilter][0]
        oldCount = self.nProducts
        # update list
        for url in newUrls:
            for fileType in productGroups[self.productFilter]:
                if fileType in url:
                    productName = url.split('/')[-1]
                    self.productList.append(productName)
                    self.dates.append(url.split('/')[-2])
        self.productList, uIndex = np.unique(self.productList,
                                             return_index=True)
        self.productList = list(self.productList)
        self.nProducts = len(self.productList)
        self.dates = [self.dates[i] for i in uIndex]
        self.newProductCount = self.nProducts - oldCount

    def boundingBox(self):
        ''' Create bounding box string for search'''
        return f'{self.LonMin.value:.2f},{self.LatMin.value:.2f},' \
            f'{self.LonMax.value:.2f},{self.LatMax.value:.2f}'

    def getURLS(self):
        ''' Get list of URLs for the product '''
        dateFormat1, dateFormat2 = '%Y-%m-%dT00:00:01Z', '%Y-%m-%dT00:23:59'
        version = versions[self.product]  # Current Version for product
        polygon = None
        bounding_box = self.boundingBox()
        pattern = '*'
        if modes[self.mode]['boxNames'] and \
                (self.product == 'NSIDC-0481' or self.product == 'NSIDC-0646'):
            pattern = f'*{self.productFilter}*'  # Include TSX box for subset
        newUrls = []
        # Future proof by increasing version if nothing found
        for i in range(0, 5):
            allUrls = grimp.get_urls(self.product, str(int(version) + i),
                                     self.firstDate.strftime(dateFormat1),
                                     self.lastDate.strftime(dateFormat2),
                                     bounding_box, polygon, pattern,
                                     verbose=self.verbose)
            if len(allUrls) > 0:  # Some found so assume version current
                break
        for url in allUrls:
            # get all urls for group (e.g., vx)
            for productGroup in productGroups[self.productFilter]:
                for suffix in fileTypes[self.productFilter]:
                    if productGroup in url and url.endswith(suffix):
                        newUrls.append(url)
        # Return filtered list sorted.
        return sorted(newUrls)

    @param.depends('product', watch=True)
    def setProductOptions(self, productFilter=None):
        self.param.productFilter.objects = productOptions[self.product]
        if productFilter is None:
            productFilter = productOptions[self.product][0]
        #
        self.param.set_param('productFilter', productFilter)
        # Reset lat/lon bounds
        for coord in ['LatMin', 'LatMax', 'LonMin', 'LonMax']:
            if self.product not in ['NSIDC-0481', 'NSIDC-0646']:
                getattr(self, coord).value = defaultBounds[coord]
                getattr(self, coord).disabled = True
            else:
                getattr(self, coord).disabled = False

    @param.depends('LatMin.value', watch=True)
    def _latMinUpdate(self):
        ''' Ensure LatMin < LatMax '''
        self.LatMax.value = max(self.LatMax.value, self.LatMin.value + 1.)

    @param.depends('LonMin.value', watch=True)
    def _lonMinUpdate(self):
        ''' Ensure LonMin < LonMax'''
        self.LonMax.value = max(self.LonMax.value, self.LonMin.value + 1.)

    @param.depends('LatMax.value', watch=True)
    def _latMaxUpdate(self):
        ''' Ensure LatMin < LatMax '''
        self.LatMin.value = min(self.LatMin.value, self.LatMax.value - 1.)

    @param.depends('LonMax.value', watch=True)
    def _lonMaxUpdate(self):
        ''' Ensure LonMin < LonMax'''
        self.LonMin.value = min(self.LonMin.value, self.LonMax.value - 1.)

    def result_view(self):
        return pn.widgets.DataFrame(self.results, height=600,
                                    autosize_mode='fit_columns')

    def TSXBoxNames(self, product='NSIDC-0481'):
        ''' Get list of all TSX boxes'''
        params = {'NSIDC-0481':
                  ('2009-01-01T00:00:01Z', '2029-01-01T00:00:01Z', 'TSX'),
                  'NSIDC-0646':
                  ('2009-01-01T00:00:01Z', '2010-01-01T00:00:01Z', 'OPT')}
        date1, date2, pattern = params[product]
        for i in range(0, 5):
            TSXurls = grimp.get_urls(product,
                                     str(int(versions[product]) + i),
                                     date1, date2,
                                     self.boundingBox(), None, '*')
            if len(TSXurls) > 0:
                return self.findTSXBoxes(urls=TSXurls, pattern=pattern)

    def findTSXBoxes(self, urls=None, pattern='TSX'):
        ''' Return list of unique boxes for the cogs '''
        if urls is None:
            urls = self.getCogs()
        boxes = list(np.unique([x.split('/')[-1].split('_')[1]
                                for x in urls if pattern in x]))
        if not boxes:  # Empty list, so fill with ''
            boxes = ['']
        return boxes

    def displayProductCount(self):
        return pn.pane.Markdown(
            f'### {self.newProductCount} New Products\n'
            f'### {self.nUrls} Total Products')

    def debugMessage(self):
        if self.debug:
            msg = f'debug {self.msg}'
        else:
            msg = ''
        return pn.pane.Markdown(msg)

    def view(self):
        ''' Display panel for getting data '''
        # Directions
        directionsPanel = pn.pane.Markdown('''
        ### Instructions:
        * Select a product, filter (e.g., speed), and date, and bounds
        * Press Search to find products,
        * Repeat procedure to append additional products.
        * Press Clear to remove all results and start over
        ''')
        # Data legend
        names = ['- **NSIDC-0642:** Terminus Locations<br/>',
                 '- **NSIDC-0723:** S1A/B Image Mosaics<br/>',
                 '- **NSIDC-0725:** Annual Velocity<br/>',
                 '- **NSIDC-0727:** Quarterly Velocity<br/>',
                 '- **NSIDC-0731:** Monthly Velocity<br/>',
                 '- **NSIDC-0766:** 6/12-Day Velocity<br/>',
                 '- **NSIDC-0481:** TSX Individual Glacier Velocity<br/>',
                 '- **NSIDC-0646:** Optical Individual Glacier Velocity'
                 ]
        searchWidgets = {'product': pn.widgets.RadioButtonGroup,
                         'productFilter': pn.widgets.Select,
                         'firstDate': pn.widgets.DatePicker,
                         'lastDate': pn.widgets.DatePicker,
                         'Search': pn.widgets.Button}

        names = [names[x] for x in modes[self.mode]['productIndexes']]
        # Clear precedence ensures this won't plot in subsetter mode
        searchWidgets['Clear'] = pn.widgets.Button
        #
        infoPanel = pn.Row(
            pn.pane.Markdown(
                f'''**Product Key: **<br/>{''.join(names[0:4])}'''),
            pn.pane.Markdown(f'''<br/>{''.join(names[4:])}'''))
        leftWidth = max(len(names) * 100, 300)
        # Search widges panel
        self.inputs = pn.Param(self.param,
                               widgets=searchWidgets,
                               name='Select Product & Parameters',
                               width=leftWidth)
        # Merge with directions
        panels = [directionsPanel, self.inputs]
        # Add lat/lon search (for none)
        if not modes[self.mode]['boxNames'] and \
                6 in modes[self.mode]['productIndexes']:
            boundsPanel = pn.Column(pn.Row(self.LatMin, self.LatMax),
                                    pn.Row(self.LonMin, self.LonMax))
            boundsLabel = pn.pane.Markdown('###Search Area (NSIDC-481 only)')
            panels += [boundsPanel, boundsLabel]
        panels += [infoPanel]
        return pn.Row(pn.Column(*panels, min_width=leftWidth),
                      pn.Column(self.result_view, self.displayProductCount,
                                self.debugMessage))

    def _formatDate(self, myDate):
        return datetime.strptime(myDate, '%Y-%m-%d').date()

    def _checkParam(self, param, options, name):
        ''' Check that "param" with "name" is in the list of "options" '''
        if param is None:
            return True
        if param not in options:
            print(f'Invalid value ({param}) for parameter ({name}).')
            print(f'Valid options are: {options}')
            return False
        #
        return True

    def _setDates(self, firstDate, lastDate):
        '''
        Set dates if specified.
        '''
        try:
            if firstDate is not None:
                self.param.set_param('firstDate', self._formatDate(firstDate))
            if lastDate is not None:
                self.param.set_param('lastDate', self._formatDate(lastDate))
        except Exception:
            print(f'Invalid Date(s): {firstDate} and/or {lastDate}')
            print('Use "YYYY-MM-DD"')
            return False
        return True

    def initialSearch(self, firstDate=None, lastDate=None, product=None,
                      productFilter=None):
        ''' This will display the panel and do an initial search '''
        # set Dates
        if not self._setDates(firstDate, lastDate):
            return
        # Set product if specified.
        if not self._checkParam(product, self.validProducts, 'product'):
            return
        if product is not None:
            self.param.set_param('product', product)
        # check productFilter
        if not self._checkParam(productFilter,
                                self.param.productFilter.objects,
                                'productFilter'):
            return
        # Update product options
        self.setProductOptions(productFilter=productFilter)
        # Run the search
        self.findData(initSearch=True)
        return self.view()
