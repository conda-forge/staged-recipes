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

import orekit
orekit.initVM()

from org.orekit.frames import FramesFactory, TopocentricFrame
from org.orekit.bodies import  OneAxisEllipsoid, GeodeticPoint
from org.orekit.time import AbsoluteDate, TimeScalesFactory
from org.orekit.orbits import KeplerianOrbit
from org.orekit.utils import Constants
from org.orekit.propagation.analytical import KeplerianPropagator
from org.orekit.utils import PVCoordinates, IERSConventions
from org.orekit.propagation.events import ElevationDetector
from org.orekit.propagation.events.handlers import EventHandler
from org.hipparchus.geometry.euclidean.threed import Vector3D
from org.orekit.python import PythonEventHandler
from org.orekit.propagation.events import EventsLogger


from math import radians
import math
import unittest
import sys

#%% Setup Orekit
from orekit.pyhelpers import  setup_orekit_curdir
setup_orekit_curdir()

#%%
class EventHandlerTest(unittest.TestCase):

    def testOwnContinueOnEvent(self):
        initialDate = AbsoluteDate(2014, 1, 1, 23, 30, 00.000, TimeScalesFactory.getUTC())
        inertialFrame = FramesFactory.getEME2000() # inertial frame for orbit definition
        position  = Vector3D(-6142438.668, 3492467.560, -25767.25680)
        velocity  = Vector3D(505.8479685, 942.7809215, 7435.922231)
        pvCoordinates = PVCoordinates(position, velocity)
        initialOrbit = KeplerianOrbit(pvCoordinates,
                                      inertialFrame,
                                      initialDate,
                                      Constants.WGS84_EARTH_MU)

        # Propagator : consider a simple keplerian motion (could be more elaborate)
        kepler = KeplerianPropagator(initialOrbit)

        #Earth and frame
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
        #%%
        class myContinueOnEvent(PythonEventHandler):

            def eventOccurred(self, s, T, increasing):
                return EventHandler.Action.CONTINUE

            def resetState(self, detector, oldState):
                return oldState

        #%% detectors
        detector = ElevationDetector(sta1Frame).withConstantElevation(elevation)
        detector = detector.withHandler(myContinueOnEvent().of_(ElevationDetector))

        logger = EventsLogger()
        kepler.addEventDetector(logger.monitorDetector(detector))

        #%%Propagate from the initial date to the first raising or for the fixed duration
        finalState = kepler.propagate(initialDate.shiftedBy(60*60*24.0*15))


        taken_passes = 0

        mylog = logger.getLoggedEvents()
        for ev in mylog:
            #print 'Date: ',ev.getState().getDate(), ' Start pass: ',ev.isIncreasing()
            if ev.isIncreasing():
                taken_passes = taken_passes + 1

        #print 'Taken passes:',taken_passes
        self.assertEquals(52, taken_passes)


if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(EventHandlerTest)
    ret = not unittest.TextTestRunner(verbosity=2).run(suite).wasSuccessful()
    sys.exit(ret)
