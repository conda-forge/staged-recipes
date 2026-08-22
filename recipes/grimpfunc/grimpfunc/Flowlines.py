#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Jan 29 12:54:33 2022

@author: ian
"""
import geopandas as gpd
import numpy as np
import functools
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


class Flowlines():
    ''' Class to read and work with flowlines from shape files '''
    shapeParsers = {'felikson': 'parseFelikson'}

    def __init__(self, shapefile=None, name=None, shapeFormat='felikson',
                 length=None, epsg=3413, sourceEpsg=None, altParser=None):
        self.flowlines = {}
        self.xforms = {}
        self.name = name
        self.setEpsg(epsg)
        if shapefile is not None:
            self.readShape(shapefile, shapeFormat=shapeFormat, altParser=altParser)
            self.truncate(None, length=length)

    def setEpsg(self, epsg):
        if epsg is str:
            epsg = int(str)
        self.epgs = epsg

    def readShape(self, shapefile, length=None, pad=10e3, reuse=False,
                  shapeFormat='felikson', sourceEpsg=None, altParser=None):
        '''
        Read a flowline shape file and return a dict with entries:
        {index: {'x': [], 'y': [], 'd': []}
        Parameters
        ----------
        shapefile : str
            Shapefile name with .shp.
        length : float, optional, the default is 50e3.
            if length > 0, keep the first part of the profile
            if length < 0, keep the last section of the profile
         pad : float, optional
            pad for bounding box. The default is 10e3.
        reuse : bool, optional
            Skip file read and used cached pandas table. The default is False.
        shapeFormat : str, optional
            Specify the parser function for the shapefile. The default is
            'felikson'.
        sourceEPSG : epsg of original data
            For future modifications with other shape parsers
        Returns
        -------
        None.
        '''
        if not reuse:
            self.shapeTable = gpd.read_file(shapefile)
        self.flowlines = {}
        if altParser is None:
            getattr(self, self.shapeParsers[shapeFormat])()
        else:
            self.flowlines = altParser(self, self.shapeTable)
        self.computeBounds(pad=pad)

    def flowlineIDs(self):
        '''
        Return a list with the flowline IDs (dict keys)
        '''
        return list(self.flowlines.keys())

    def parseFelikson(self):
        '''
        Parse lines from Felikson flowlines from
        https://zenodo.org/record/4284759#.YfWxl4TMLLR
        Returns
        -------
        None.
        '''
        for index, row in self.shapeTable.iterrows():  # loop over features
            fl = {}  # New Flowline
            fl['x'], fl['y'] = np.array(
                [c for c in row['geometry'].coords]).transpose()
            # Compute distance along profile
            fl['d'] = self.computeDistance(fl['x'], fl['y'])
            self.flowlines[row['flowline']] = fl

    def truncate(self, indices, length=50e3, pad=10e3):
        '''
        Parameters
        ----------
        indices : list of indices of flowlines to truncate
            DESCRIPTION.
        length : float, optional, the default is 50e3.
            if length > 0, keep the first part of the profile
            if length < 0, keep the last section of the profile
        pad : float, optional
            pad for bounding box. The default is 10e3.
        Returns
        -------
        None.
        '''
        if length is None:
            return
        if indices is None:
            indices = self.flowlines.keys()
        elif type(indices) is not list:
            indices = [indices]
        # determine portion of profile to keep
        for i in indices:
            if length > 0:
                keep = self.flowlines[i]['d'] < length
            else:
                keep = self.flowlines[i]['d'] > (self.flowlines[i]['d'][-1] +
                                                 length)
            # clip
            for key in ['x', 'y', 'd']:
                self.flowlines[i][key] = self.flowlines[i][key][keep]
        # Update bounding box
        self.computeBounds(pad=pad)

    def computeDistance(self, x, y):
        '''
        Compute distance along a flowline from x and y coordinates.
        Parameters
        ----------
        x, y : np.array
            x, y coordinates.
        Returns
        -------
        np.array
            Distance along profile.
        '''
        dl = np.zeros(x.shape)
        dl[1:] = np.sqrt(np.diff(x)**2 + np.diff(y)**2)
        return np.cumsum(dl)

    def computeBounds(self, pad=10e3):
        '''
        Compute the padded bounding the box for the profiles
        self.bounds = {'minx': ...'maxy': }
        Parameters
        ----------
        pad : float, optional
            Additial padd around the bounding box. The default is 10e3.
        Returns
        -------
        None.

        '''
        keysTemplate = ['minx', 'miny', 'maxx', 'maxy']
        self.bounds = dict(zip(keysTemplate, [1e9, 1e9, -1e9, -1e9]))
        for fl in self.flowlines.values():
            values = np.around([np.min(fl['x']) - pad, np.min(fl['y']) - pad,
                                np.max(fl['x']) + pad, np.max(fl['y']) + pad],
                               - 2)
            newBounds = dict(zip(keysTemplate, values))
            self.bounds = self.mergeBounds(self.bounds, newBounds)

    def mergeBounds(self, bounds1, bounds2):
        '''
        Merge two bounding bounding boxes as the union of the extents.
        Parameters
        ----------
        bounds1, bounds2 : bounding box dicts
            {'minx': ..., 'miny': ..., 'maxx': ..., 'maxy': ...}.
        Returns
        -------
        bounds1 : bounding box dict
            Merged box.
        '''
        merged = {}
        merged['minx'] = np.min([bounds1['minx'], bounds2['minx']])
        merged['miny'] = np.min([bounds1['miny'], bounds2['miny']])
        merged['maxx'] = np.max([bounds1['maxx'], bounds2['maxx']])
        merged['maxy'] = np.max([bounds1['maxy'], bounds2['maxy']])
        return merged

    def _toKm(func):
        '''
        Decorator for unit conversion
        Parameters
        ----------
        func : function
            function to be decorated.
        Returns
        -------
        float
            Coordinates converted to km from m.
        '''
        @functools.wraps(func)
        def convertKM(*args, **kwargs):
            result = func(*args, **kwargs)
            if type(result) is not tuple:
                return result * 0.001
            else:
                return [x*0.001 for x in result]
        return convertKM

    def xy(self, index=None, units='m'):
        '''
        Return the x and y flowline coordinates in meters or km (units)
        Parameters
        ----------
        index : str, optional
            Index of flowline, defaults to the first flowline for if None.
        units :  str, optional
            Units in 'm' or 'km', default is 'm'
        Returns
        -------
        np.array, np.array
            x, y in coordinates in m
        '''
        # Return None if bad units
        if not self.checkUnits(units):
            return None
        # select flowline
        if index is None:
            index = list(self.flowlines)[0]
        # compute scale and return
        scale = {'m': 1, 'km': 0.001}[units]
        return self.flowlines[index]['x'] * scale, \
            self.flowlines[index]['y'] * scale

    def flowlineDistance(self, index=None, units='m'):
        '''
        Return the distance along a flowline in m or km (units)
        ----------
        index : str, optional
            Index of flowline, defaults to the first flowline for if None.
        units :  str, optional
            Units in 'm' or 'km', default is 'm'
        Returns
        -------
        np.array, np.array
            x, y in coordinates in m
        '''
        # Return None if bad units
        if not self.checkUnits(units):
            return None
        # select flowline
        if index is None:
            index = list(self.flowlines)[0]
        # compute scale and return
        scale = {'m': 1, 'km': 0.001}[units]
        return self.flowlines[index]['d'] * scale

    def plotGlacierName(self, ax=plt, units='m', index=None, first=True,
                        xShift=0, yShift=0, **kwargs):
        '''
        Plot glacier name on map

        Parameters
        ----------
        ax : matplot lib ax, optional
            axsis for plot. The default is plt.
        units : str, optional
            Select units as 'm' or 'km'. The default is 'm'.
        index : str, optional
            index for flowline to locate label near. The default is None.
        first : TYPE, optional
            locate label at flowline start, ow at the end. The default is True.
        xShift : number, optional
            Amount to shift label in map units. The default is 0.
        yShift : TYPE, optional
            Amount to shift label in map units. The default is 0.
        **kwargs : TYPE
            DESCRIPTION.
        Returns
        -------
        None.

        '''
        if not self.checkUnits(units):
            return
        #
        x, y = self.xy(index=index, units=units)
        if first:
            xL, yL, hAlign = x[0], y[0], 'right'
        else:
            xL, yL, hAlign = x[-1], y[-1], 'left'
        #
        ax.text(xL + xShift, yL + yShift, self.name,
                horizontalalignment=hAlign, **kwargs)

    def extractPoint(self, distance, index, units='m'):
        '''
        Extract a point distance from start of flowline (nearest point)

        Parameters
        ----------
        distance : distance in appropriate units
            DESCRIPTION.
        index : str
            flowline id.
        units : str, optional
            Units 'm' or 'km'. The default is 'm'.
        Returns
        -------
        x, y : coordinates of point.

        '''
        i = np.argmin(np.abs(self.flowlineDistance(index=index, units=units) -
                             distance))
        #
        x, y = self.xy(index=index, units=units)
        return x[i], y[i]

    def extractPoints(self, distance, indices=None, units='m'):
        '''
        Extract a point distance from start of flowines specified by None

        Parameters
        ----------
        distance : distance in appropriate units
            DESCRIPTION.
        indces : list
            list of indices, None will results for all flowlines.
        units : str, optional
            Units 'm' or 'km'. The default is 'm'.
        Returns
        -------
        points : {index: x, y...}
        '''
        if indices is None:
            indices = self.flowlineIDs()
        return {ID: (self.extractPoint(distance, ID, units=units))
                for ID in indices}

    def genColorDict(self, flowlineIDs=None):
        '''
        Generate a color map index by flowline ids
        An outside list can be used to create a list than spans severa
        glaciers (e.g., the union of all flowline ids).
        Will recycle colors if ids > 10
        Parameters
        ----------
        flowlineIDs : list, optional
            flowline ids. The default is ids for this instance.

        Returns
        -------
        None.

        '''
        if flowlineIDs is None:
            flowlineIDs = self.flowlineIDs()
        colors = mcolors.TABLEAU_COLORS.values()
        # Cycle colors if more are needed
        while len(colors) < len(flowlineIDs):
            colors += mcolors.TABLEAU_COLORS.values()
        return {ID: c for ID, c in zip(flowlineIDs, colors)}

    def checkUnits(self, units):
        '''
        Check units return True for valid units. Print message for invalid.
        '''
        if units not in ['m', 'km']:
            print('Invalid units: must be m or km')
            return False
        return True

    def plotFlowlineLocations(self, ax=plt, units='m', indices=None,
                              colorDict=None, **kwargs):
        '''
        Plot all flowline locations or a single location given by index
        Parameters
        ----------
        ax : matplotlib ax, optional
            The axis used for the plot. The default is plt.
        units : str, optional
            Units 'm' or 'km'. The default is 'm'.
        index : TYPE, optional
            DESCRIPTION. The default is None.
        **kwargs : TYPE
            DESCRIPTION.

        Returns
        -------
        None.
        '''
        # the units conversion to apply
        if not self.checkUnits(units):
            return
        # color map
        if colorDict is None:
            colorDict = self.genColorDict()
        # Default is all indices
        if indices is None:
            indices = self.flowlines.keys()
        elif type(indices) is not list:
            indices = [indices]
        # plot lines
        for index in indices:
            ax.plot(*self.xy(index=index, units=units),
                    color=colorDict[index], label=index, **kwargs)
