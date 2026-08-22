#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr 16 15:50:52 2021

@author: ian
"""
import holoviews as hv
import numpy as np
from bokeh.models.formatters import DatetimeTickFormatter
import panel as pn
# from datetime import datetime

defaultImgOpts = {'vv': {'clim': (0, 3000), 'logz': True, 'cmap': 'viridis'},
                  'vx': {'clim': (-1500, 1500), 'logz': False, 'cmap': 'bwr'},
                  'vy': {'clim': (-1500, 1500), 'logz': False, 'cmap': 'bwr'},
                  'ex': {'clim': (0, 20), 'logz': False, 'cmap': 'Magma'},
                  'ey': {'clim': (0, 20), 'logz': False, 'cmap': 'Magma'},
                  'dT': {'clim': (-30, 30), 'logz': False, 'cmap': 'bwy'},
                  'image': {'clim': (0, 255), 'logz': False, 'cmap': 'gray'},
                  'sigma0': {'clim': (-30, 20), 'logz': False, 'cmap': 'gray'},
                  'gamma0': {'clim': (-30, 20), 'logz': False, 'cmap': 'gray'}
                  }

defaultPlotOpts = {'vv': {'ylabel': 'Speed (m/yr)', 'xlabel': 'Date'},
                   'vx': {'ylabel': 'vx (m/yr)', 'xlabel': 'Date'},
                   'vy': {'ylabel': 'vy (m/yr)', 'xlabel': 'Date'},
                   'ex': {'ylabel': '$ex (m/yr)$', 'xlabel': 'Date'},
                   'ey': {'ylabel': 'ey (m/yr)', 'xlabel': 'Date'},
                   'dT': {'ylabel': 'dT (days)', 'xlabel': 'Date'},
                   'image': {'ylabel': 'DN', 'xlabel': 'Date'},
                   'sigma0': {'ylabel': r'$\gamma_o$ (dB)', 'xlabel': 'Date'},
                   'gamma0': {'ylabel': r'$\gamma_o$ (dB)', 'xlabel': 'Date'}
                   }

noDataValues = {'vv': -1.0, 'vx': -2.0e9, 'vy': -2e9, 'ex': -1.0,
                'ey': -1.0, 'dT': -2.e9, 'image': 0, 'gamma0': -30.,
                'sigma0': -30}


class pointInspector():
    ''' Input an xarray is stacked xy
    planes in time with multiple components X[time][component][x][y].
    Then display a map of the result so that users can pick points to be
    plotted as a time series.
    '''

    def __init__(self, xArray, noData=None, component='vv'):
        '''
        Initilzation routine.
        Parameters
        ----------
        xArray : xarray
            X[time][component][x][y]..
        noData : TYPE, optional
            No data value. The default is None.
        component : string, optional
            The component to plot (data dependent). The default is 'vv'.
        Returns
        -------
        None.
        '''
        self.setData(xArray)
        self.component = component
        self.setNoDataValue(noData=noData)
        self.dtf = DatetimeTickFormatter(years="%Y")
        # Assumes data set has one var and possible a spatial_ref
        # This step avoids using the spatial ref
        #names = list(self.xArray.keys())
        #if 'spatial_ref' in names:
       #     names.remove('spatial_ref')
        self.name = xArray.name
        # print(self.name)

    def setNoDataValue(self, noData=None):
        ''' Set the no data value '''
        if noData is not None:
            self.noData = noData
        else:
            # increase slightly to > test works
            self.noData = noDataValues[self.component] + 1e-6

    def setData(self, xArray):
        ''' Setup internal refs to xarray along with bounds and center '''
        self.xArray = xArray
        self.bounds = self.productBounds(xArray)
        self.xc, self.yc = self.centerPoint()

    def _removeNoData(self, t, v):
        ''' processs np array to remove no data and return as lists. If
        all no data return original'''
        if np.isnan(self.noData):
            keep = np.isfinite(v)
        else:
            keep = v > self.noData
        # Save valid values
        if len(keep) > 0:
            v = v[keep]
            t = t[keep]
        return list(t), list(v)

    def extractData(self, x, y, **kwargs):
        ''' Plot the time series, filtering out no data values '''
        # get data and time values
        vOrig = self.xArray.sel(band=self.component).sel(
            x=x, y=y, method='nearest').values.flatten()
        tOrig = self.xArray.time.values.flatten()
        t, v = self._removeNoData(tOrig, vOrig)
        # Plot points and lines- options need some work
        return hv.Curve((t, v)).opts(**self.plotOptions) * \
            hv.Scatter((t, v)).opts(color='red', size=4, framewise=True,
                                    xformatter=self.dtf, **self.plotOptions)

    def productBounds(self, xArray):
        ''' Return dict with bounds in time and space'''
        keys = ['minx', 'miny', 'maxx', 'maxy', 'mint', 'maxt']
        extremes = [min(xArray.x.values), min(xArray.y.values),
                    max(xArray.x.values), max(xArray.y.values),
                    min(xArray.time.values), max(xArray.time.values)]
        return dict(zip(keys, extremes))

    def centerPoint(self):
        ''' Compute center point of bounding box'''
        xc = (self.bounds['minx'] + self.bounds['maxx']) * .5
        yc = (self.bounds['miny'] + self.bounds['maxy']) * .5
        return xc, yc

    def _imgOpts(self, component, **kwargs):
        ''' Return a copy of the default image options '''
        opts = defaultImgOpts[component].copy()
        for key in kwargs:
            if key in opts:
                opts[key] = kwargs[key]
        return opts

    def _plotOpts(self, component, **kwargs):
        ''' Return a copy of the default plot options '''
        opts = defaultPlotOpts[component].copy()
        for key in kwargs:
            # print(key,opts)
            if key in opts:
                opts[key] = kwargs[key]
        if 'plotTitle' in kwargs:
            opts['title'] = kwargs['plotTitle']
        return opts

    def view(self, component='vv', mapTitle=None, ncols=2, time=None, **kwargs):
        ''' Setup and return plot '''
        self.component = component
        self.setNoDataValue(None)
        self.plotOptions = self._plotOpts(component, **kwargs)
        self.imgOptions = self._imgOpts(component, **kwargs)
        # Default titles
 
        # Setup the image plot.
        if time is None:
            time = self.bounds['maxt']
        if mapTitle is None:
            mapTitle = 'xxx' #component + time
        img = self.xArray.sel(band=self.component,
                                         time=time)
        imgPlot = img.hvplot.image(rasterize=True, aspect='equal',
                                   title=mapTitle).opts(
                                       active_tools=['point_draw'],
                                       **self.imgOptions)
        # Setup up the time series plot
        points = hv.Points(([self.xc], [self.yc]), ).opts(size=6, color='red')
        pointer = hv.streams.PointDraw(source=points,
                                       data=points.columns(), num_objects=1)
        # Create the dynamic map
        pointer_dmap = hv.DynamicMap(
            lambda data: self.extractData(data['x'][0], data['y'][0]),
            streams=[pointer]).opts(width=500)
        # Return the result for display
        return pn.panel((imgPlot * points +
                         pointer_dmap).cols(ncols).opts(merge_tools=False))
