# -*- coding: utf-8 -*-

"""

/* Copyright 2002-2013 CS Syst��mes d'Information
 * Licensed to CS Syst��mes d'Information (CS) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * CS licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

Python version translated from Java by Petrus Hyvönen, SSC 2014

 """

import  orekit
orekit.initVM()
from orekit.pyhelpers import  setup_orekit_curdir
setup_orekit_curdir()

from org.orekit.bodies import GeodeticPoint
from org.orekit.bodies import OneAxisEllipsoid
from org.orekit.frames import TopocentricFrame
from org.orekit.orbits import KeplerianOrbit
from org.orekit.frames import FramesFactory
from org.orekit.orbits import PositionAngle
from org.orekit.propagation.analytical import KeplerianPropagator
from org.orekit.propagation.events.handlers import EventHandler
from org.orekit.python import PythonEventHandler
from org.orekit.time import AbsoluteDate
from org.orekit.time import TimeScalesFactory
from org.orekit.utils import Constants
from org.orekit.utils import IERSConventions
from org.orekit.propagation.events import ElevationDetector
import unittest
import sys
import math


class Visibility(PythonEventHandler): # implements EventHandler<ElevationDetector> {
       
        def __init__(self):
            self._visiNb = 0
            super(Visibility, self).__init__()
        
        def getVisiNb(self): 
            return self._visiNb
        
        def eventOccurred(self, s, ed, increasing):
            self._visiNb += 1
            return EventHandler.Action.CONTINUE
#     
        def resetState(self, detector,  oldState):
            return oldState
        
class BackAndForthDetectorTest(unittest.TestCase):

    def testBackAndForth(self):
        utc = TimeScalesFactory.getUTC()
        date0 = AbsoluteDate(2006, 12, 27, 12,  0, 0.0, utc)
        date1 = AbsoluteDate(2006, 12, 27, 22, 50, 0.0, utc)
        date2 = AbsoluteDate(2006, 12, 27, 22, 58, 0.0, utc)

        # Orbit
        a = 7274000.0
        e = 0.00127
        i = math.radians(90.)
        w = math.radians(0.)
        raan = math.radians(12.5)
        lM = math.radians(60.)
        iniOrb = KeplerianOrbit(a, e, i, w, raan, lM,
                                          PositionAngle.MEAN, 
                                          FramesFactory.getEME2000(), date0,
                                          Constants.WGS84_EARTH_MU)

        # Propagator
        propagator = KeplerianPropagator(iniOrb)

        # Station
        stationPosition = GeodeticPoint(math.radians(0.), math.radians(100.), 110.)
        earth = OneAxisEllipsoid(Constants.WGS84_EARTH_EQUATORIAL_RADIUS,
                                                     Constants.WGS84_EARTH_FLATTENING,
                                                     FramesFactory.getITRF(IERSConventions.IERS_2010, True))

        stationFrame = TopocentricFrame(earth, stationPosition, "")

        # Detector
        visi = Visibility() #.of_(ElevationDetector);
        det = ElevationDetector(stationFrame).withConstantElevation(math.radians(10.0)).withHandler(visi)   
        propagator.addEventDetector(det)

        # Forward propagation (AOS + LOS)
        propagator.propagate(date1)
        propagator.propagate(date2)
        # Backward propagation (AOS + LOS)
        propagator.propagate(date1)
        propagator.propagate(date0)

        self.assertEquals(4, visi.getVisiNb())

if __name__ == '__main__':
    #unittest.main()
    
    suite = unittest.TestLoader().loadTestsFromTestCase(BackAndForthDetectorTest)
    ret = not unittest.TextTestRunner(verbosity=2).run(suite).wasSuccessful()
    sys.exit(ret)

