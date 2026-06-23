#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Apr  7 08:43:45 2021

@author: ian basedon prototype by Scott Henderson
"""

import xarray as xr
import rioxarray
import os
import dask
import pandas as pd
# from dask.diagnostics import ProgressBar
# ProgressBar().register()
import stackstac
import rio_stac
import pystac

CHUNKSIZE = 512

productTypeDict = {'velocity': {'bands': ['vv', 'vx', 'vy'], 'template': 'vv',
                                'index1': 4, 'index2': 5},
                   'image': {'bands': ['image'], 'template': 'image',
                             'index1': 3, 'index2': 4},
                   'gamma0': {'bands': ['gamma0'], 'template': 'gamma0',
                              'index1': 3, 'index2': 4},
                   'sigma0': {'bands': ['sigma0'], 'template': 'sigma0',
                              'index1': 3, 'index2': 4}}

# valid bands and the reference url type
# NOTE NSIDC-0481: TSX Individual Glacier Velocity resolution=100
# Other resolutions = 200m
bandsDict = {'vv': {'template': 'vv', 'noData': -1., 'name': 'velocity'},
             'vx': {'template': 'vv', 'noData': -2.e9, 'name': 'velocity'},
             'vy': {'template': 'vv', 'noData': -2.e9, 'name': 'velocity'},
             'ex': {'template': 'vv', 'noData': -1., 'name': 'velocity'},
             'ey': {'template': 'vv', 'noData': -1., 'name': 'velocity'},
             'dT': {'template': 'vv', 'noData': -2.e9, 'name': 'velocity'},
             'image': {'template': 'image', 'noData': 0, 'name': 'image'},
             'gamma0': {'template': 'gamma0', 'noData': -30.,
                        'name': 'gamma0'},
             'sigma0': {'template': 'sigma0', 'noData': -30., 'name': 'sigma0'}
             }


class GrIMPSubsetter():
    ''' Class to open remote data set and create a rioxarry. The result can
    then be cropped to create a subset, which can then be saved to a netcdf'''

    def __init__(self, bands=['vv'], urls=None, tiffs=None, numWorkers=4):
        self.urls = urls
        if tiffs is not None:
            self.urls = tiffs  # No longer seperate urls from tifs
        if urls is not None and tiffs is not None:
            print('Warning: specify only tifs or urls proceeding with\n'
                  f'{self.urls}')
        self.DA = None
        self.dataArrays = None
        self.subset = None
        self.dtype = None
        self.bands = self._checkBands(bands)
        self.noDataDict =  {'vx': -2.0e9, 'vy': -2.0e9, 'vv': -1.0,
                           'ex': -1.0, 'ey': -1.0, 'image': 0, 'gamma0': -30.,
                           'sigma0': -30.}
        dask.config.set(num_workers=numWorkers)
        print('Depricated: Uses nisarVel, nisarVelSeries, nisarImage, or '
              'nisarImageSeries')

    def get_stac_item_template(self, URLs):
        '''
        read first geotiff to get STAC Item template (returns pystac.Item)
        '''
        template = bandsDict[self.bands[0]]['template']
        first_url = URLs[0].replace(template, self.bands[0]) 
        print(first_url)
        productType = bandsDict[self.bands[0]]['name']
        index1 = productTypeDict[productType]['index1']
        index2 = productTypeDict[productType]['index2']
        date, _ = self.datesFromGrimpName(os.path.basename(first_url),
                                          index1=index1, index2=index2)
        # collection = first_url.split('/')[-3],
        fill_values = [self.noDataDict[band] for band in self.bands]
        item = rio_stac.create_stac_item(first_url,
                                         input_datetime=date,
                                         asset_media_type=str(
                                             pystac.MediaType.COG),
                                         with_proj=True,
                                         with_raster=True,
                                         )
        self.dtype = \
            item.assets['asset'].extra_fields['raster:bands'][0]['data_type']
        # Could remove: #['links'] #['assets']['asset']['roles']
        # Remove statistics and histogram, b/c only applies to first
        item.assets['asset'].extra_fields['raster:bands'][0].pop('statistics')
        item.assets['asset'].extra_fields['raster:bands'][0].pop('histogram')
        return item

    def construct_stac_items(self, URLs):
        ''' construct STAC-style dictionaries of CMR urls for stackstac '''
        # maintain seperate asset templates by band
        asset_templates = {}
        item_template = self.get_stac_item_template(URLs)
        for band in self.bands:
            band_template = bandsDict[band]['template']
            url = URLs[0].replace(band_template, band)
            asset_templates[band] = \
                self.get_stac_item_template([url]).assets.pop('asset')
        #
        ITEMS = []
        for url in URLs:
            item = item_template.clone()
            print('.',end='')
            # works with single asset per item datasets (e.g. only gamma0 urls)
            item.id = os.path.basename(url)
            productType = bandsDict[self.bands[0]]['name']
            index1 = productTypeDict[productType]['index1']
            index2 = productTypeDict[productType]['index2']
            date1, date2 = self.datesFromGrimpName(item.id, index1=index1,
                                                   index2=index2)
            item.datetime = date1 + (date2 - date1) * 0.5
            for band in self.bands:
                band_template = bandsDict[band]['template']
                asset_template = asset_templates[band]
                asset_template.href = url.replace(band_template, band)
                #
                item.add_asset(band, asset_template)
                itemDict = item.to_dict()

            ITEMS.append(itemDict)

        return ITEMS

    def lazy_open_stackstac(self, items):
        ''' return stackstac xarray dataarray '''
        fill_values = [self.noDataDict[band] for band in self.bands]
        da = stackstac.stack(items,
                             fill_value=0,
                             assets=self.bands,
                             chunksize=CHUNKSIZE,
                             # NOTE: use native projection, match rioxarray
                             snap_bounds=False,  # default=True
                             xy_coords='center',  # default='topleft'
                             dtype=self.dtype
                             )
        # da = da.rename(band='component')
        return da

    def datesFromGrimpName(self, filename, index1=4, index2=5):
        '''
        Parse grimp filename to get dates
        Parameters
        ----------
        filename : str
            product file name.
        index1 : int, optional
            date1 location in "_" seperated filename. The default is 4.
        index2 : int, optional
            date2 location in "_" seperated filename. The default is 5.
        Returns
        -------
        date1, date2, datetime
            First and second names from date str.
        '''
        date1 = filename.split('_')[index1]
        date2 = filename.split('_')[index2]
        return pd.to_datetime(date1), pd.to_datetime(date2)

    #@dask.delayed
    def lazy_open(self, url, masked=True, chunkSize=512):
        '''
        Lazy open of a single url

        Parameters
        ----------
        url : str
            url name.
        masked : boolean, optional
            Masked flag to xarray The default is False.
        chunkSize : int, optional
            Chunk size. The default is 512.

        Returns
        -------
        TYPE
            DESCRIPTION.

        '''
        # print(href)
        das = []
        chunks = {'band': 1, 'y': chunkSize, 'x': chunkSize}
        for band in self.bands:
            productType = bandsDict[band]['name']
            template = bandsDict[band]['template']
            filename = os.path.basename(url)
            index1 = productTypeDict[productType]['index1']
            index2 = productTypeDict[productType]['index2']
            date1, date2 = self.datesFromGrimpName(filename, index1=index1,
                                                   index2=index2)
            url = url.replace(template, band)
            if 'https' in url:
                option = '?list_dir=no'
            # swap temnplate for other bands
                url = f'/vsicurl/{option}&url={url}'
            # create rioxarry
            da = rioxarray.open_rasterio(url, lock=True,
                                         default_name=bandsDict[band]['name'],
                                         chunks=chunks,
                                         masked=masked).rename(
                                             band='band')
            da['band'] = [band]
            da['time'] = date1 + (date2 - date1) * 0.5
            da['time1'] = date1
            da['time2'] = date2
            da['name'] = filename
            da['_FillValue'] = bandsDict[band]['noData']
            das.append(da)
        # Concatenate bands (components)
        return xr.concat(das, dim='band', join='override',
                         combine_attrs='drop')

    def getBounds(self):
        ''' Get the bounding box for the data array '''
        bounds = [min(self.DA.x.values), min(self.DA.y.values),
                  max(self.DA.x.values), max(self.DA.y.values)]
        keys = ['minx', 'miny', 'maxx', 'maxy']
        return dict(zip(keys, bounds))

    def _checkBands(self, bands):
        ''' Check valid band types '''
        if bands is None and self.bands is not None:
            # print(bands, self.bands)
            return self.bands
        for band in bands:
            if band not in bandsDict:
                print(f'\x1b[1;33mIgnoring Invalid Band: {band}.\x1b[0m\n'
                      f'Allowed bands: {list(bandsDict.keys())}')
                bands.remove(band)
        return bands

    def loadStackStac(self, bands=None):
        ''' construct dataarray with stackstac '''
        self.bands = self._checkBands(bands)
        items = self.construct_stac_items(self.urls)
        self.DA = self.lazy_open_stackstac(items)

    def loadDataArray(self, bands=None, chunkSize=512):
        ''' Load and concatenate arrays to create a rioxArray with coordinates
        time, band, y, x'''
        # NOTE: can have server-size issues w/ NSIDC if going above 15 threads
        # if psutil.cpu_count() > 15: num_threads = 12
        self.bands = self._checkBands(bands)
        with dask.config.set({'scheduler': 'threads', 'num_workers': 2}):
            # if self.urls is not None:
            self.dataArrays = dask.compute(
                *[self.lazy_open(url, masked=False, chunkSize=chunkSize)
                  for url in self.urls])
        # Concatenate along time dimensions
        self.DA = xr.concat(self.dataArrays, dim='time', join='override',
                            combine_attrs='drop')

    def subSetData(self, bbox):
        ''' Subset dataArray with
        bbox = {'minx': minx, 'miny': miny, 'maxx': maxx, 'maxy': maxy}
        '''
        self.subset = self.DA.rio.clip_box(**bbox)
        return self.subset

    def saveAll(self, cdfFile, numWorkers=4):
        ''' Save the entire data array as a subset of the entire extent'''
        self.subSetToNetCDF(cdfFile, bbox=self.getBounds(),
                            numWorkers=numWorkers)

    def subSetToNetCDF(self, cdfFile, bbox=None, numWorkers=1):
        ''' Write existing subset or update subset. Will append .nc to cdfFile
        if not already present.
        '''
        if bbox is not None:
            self.subSetData(bbox)
        if self.subset is None:
            print('No subset present - set bbox={"minxx"...}')
            return
        if '.nc' not in cdfFile:
            cdfFile = f'{cdfFile}.nc'
        if os.path.exists(cdfFile):
            os.remove(cdfFile)
        for x in self.subset.coords:
            if 'proj' in x or 'raster' in x or 'spec' in x:
                self.subset = self.subset.drop(x, dim=None)
        for x in self.subset.attrs:
            if 'spec' in x:
                self.subset = self.subset.drop(x, dim=None)
        # To many workers can cause a failure
        with dask.config.set({'scheduler': 'threads',
                              'num_workers': numWorkers}):
            self.subset.to_netcdf(path=cdfFile)
        return cdfFile

    def readFromNetCDF(self, cdfFile):
        '''
        Load data from netcdf file
        Parameters
        ----------
        cdfFile : str
            NetCDF file name.
        Returns
        -------
        None.
        '''
        if '.nc' not in cdfFile:
            cdfFile = f'{cdfFile}.nc'
        xDS = xr.open_dataset(cdfFile, chunks='auto')
        # Pull the first variable that is not spatial_ref
        for var in list(xDS.data_vars.keys()):
            if var != 'spatial_ref':
                self.DA = xDS[var]
                break
        return xDS
        try:
            self.DA['spatial_ref'] = xDS['spatial_ref']
        except Exception:
            print('warning missing spatial_ref')
        #
        self.subset = self.DA  # subset is whole array at this point.
