# -*- coding: utf-8 -*-

import orekit
orekit.initVM()

from org.orekit.frames import FramesFactory, TopocentricFrame
from org.orekit.bodies import  OneAxisEllipsoid, GeodeticPoint
from org.orekit.time import AbsoluteDate, TimeScalesFactory
from org.orekit.orbits import KeplerianOrbit
from org.orekit.utils import Constants
from org.orekit.propagation.analytical import KeplerianPropagator
from org.orekit.utils import PVCoordinates, IERSConventions
from org.orekit.propagation.events.handlers import EventHandler
from org.hipparchus.geometry.euclidean.threed import Vector3D
from org.orekit.python import PythonEventHandler, PythonAbstractDetector
from org.orekit.propagation.events.handlers import ContinueOnEvent, StopOnEvent

from math import radians
import math
import unittest
import sys

from orekit.pyhelpers import  setup_orekit_curdir
setup_orekit_curdir()

class PassCounter(PythonEventHandler):
    """Eventhandler that counts positive events"""
    passes = 0

    def eventOccurred(self, s, T, increasing):
        if increasing:
            self.passes = self.passes + 1

        return EventHandler.Action.CONTINUE

    def resetState(self, detector, oldState):
        return oldState


class MyElevationDetector(PythonAbstractDetector):

    def __init__(self, elevation, topo, handler=None):
        self.elevation = elevation
        self.topo = topo

        dmax = float(PythonAbstractDetector.DEFAULT_MAXCHECK)
        dthresh = float(PythonAbstractDetector.DEFAULT_THRESHOLD)
        dmaxiter = PythonAbstractDetector.DEFAULT_MAX_ITER
        if handler is None:
            handler = StopOnEvent().of_(MyElevationDetector)

        super(MyElevationDetector, self).__init__(dmax, dthresh, dmaxiter, handler) #super(maxCheck, threshold, maxIter, handler);

    def init(self, *args, **kw):
        pass

    def getElevation(self):
        return self.elevation

    def getTopocentricFrame(self):
        return self.topo

    def g(self, s):
        tmp = self.topo.getElevation(s.getPVCoordinates().getPosition(), s.getFrame(), s.getDate())-self.elevation
        return tmp

    def create(self, newMaxCheck, newThreshHold, newMaxIter, newHandler):
        return MyElevationDetector(self.elevation, self.topo, handler=newHandler)

class AbstractDetectorTest(unittest.TestCase):

    def testOwnElevationDetector(self):

        initialDate = AbsoluteDate(2014, 1, 1, 23, 30, 00.000, TimeScalesFactory.getUTC())
        inertialFrame = FramesFactory.getEME2000() # inertial frame for orbit definition
        position  = Vector3D(-6142438.668, 3492467.560, -25767.25680)
        velocity  = Vector3D(505.8479685, 942.7809215, 7435.922231)
        pvCoordinates = PVCoordinates(position, velocity)
        initialOrbit = KeplerianOrbit(pvCoordinates,
                                      inertialFrame,
                                      initialDate,
                                      Constants.WGS84_EARTH_MU)

        kepler = KeplerianPropagator(initialOrbit)

        ITRF = FramesFactory.getITRF(IERSConventions.IERS_2010, True)
        earth = OneAxisEllipsoid(Constants.WGS84_EARTH_EQUATORIAL_RADIUS,
                                 Constants.WGS84_EARTH_FLATTENING,
                                 ITRF)

        # Station
        longitude = radians(45.0)
        latitude  = radians(25.0)
        altitude  = 0
        station1 = GeodeticPoint(latitude, longitude, float (altitude))
        sta1Frame = TopocentricFrame(earth, station1, "station 1")

        elevation = math.radians(5.0)

        detector = MyElevationDetector(elevation, sta1Frame)

        mycounter = PassCounter().of_(MyElevationDetector)
        detector = detector.withHandler(mycounter)

        kepler.addEventDetector(detector)

        finalState = kepler.propagate(initialDate.shiftedBy(60*60*24.0*15))

        print(mycounter.passes)
        self.assertEquals(52, mycounter.passes)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(AbstractDetectorTest)
    ret = not unittest.TextTestRunner(verbosity=2).run(suite).wasSuccessful()
    sys.exit(ret)
