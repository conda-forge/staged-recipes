# -*- coding: utf-8 -*-

"""

/* Copyright 2002-2016 CS Syst��mes d'Information
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

Python version translated from Java by Petrus Hyvönen, SSC 2016

 """

import orekit

orekit.initVM()

from org.orekit.frames import FramesFactory, TopocentricFrame
from org.orekit.bodies import OneAxisEllipsoid, GeodeticPoint
from org.orekit.time import AbsoluteDate
from org.orekit.orbits import KeplerianOrbit, PositionAngle
from org.orekit.utils import Constants
from org.orekit.propagation.analytical import KeplerianPropagator
from org.orekit.utils import IERSConventions
from org.orekit.propagation.events import ElevationDetector, EventsLogger, FieldOfView, GroundFieldOfViewDetector
from org.hipparchus.geometry.euclidean.threed import Vector3D

from math import radians
import math
import unittest
import sys

from orekit.pyhelpers import setup_orekit_curdir

setup_orekit_curdir()


class GroundFieldOfViewDetectorTest(unittest.TestCase):
    def testGroundFieldOfViewDetector(self):
        date = AbsoluteDate.J2000_EPOCH  # arbitrary date
        endDate = date.shiftedBy(Constants.JULIAN_DAY)
        eci = FramesFactory.getGCRF()
        ecef = FramesFactory.getITRF(IERSConventions.IERS_2010, True)
        earth = OneAxisEllipsoid(
            Constants.WGS84_EARTH_EQUATORIAL_RADIUS,
            Constants.WGS84_EARTH_FLATTENING,
            ecef)

        gp = GeodeticPoint(radians(39), radians(77), 0.0)
        topo = TopocentricFrame(earth, gp, "topo")

        # iss like orbit
        orbit = KeplerianOrbit(
            6378137.0 + 400e3, 0.0, radians(51.65), 0.0, 0.0, 0.0,
            PositionAngle.TRUE, eci, date, Constants.EGM96_EARTH_MU)

        prop = KeplerianPropagator(orbit)

        # compute expected result
        elevationDetector = ElevationDetector(topo).withConstantElevation(math.pi / 6.0).withMaxCheck(5.0)
        logger = EventsLogger()
        prop.addEventDetector(logger.monitorDetector(elevationDetector))
        prop.propagate(endDate)
        expected = logger.getLoggedEvents()

        # action
        # construct similar FoV based detector
        # half width of 60 deg pointed along +Z in antenna frame
        # not a perfect small circle b/c FoV makes a polygon with great circles

        fov = FieldOfView(Vector3D.PLUS_K, Vector3D.PLUS_I, math.pi / 3.0, 16, 0.0)

        # simple case for fixed pointing to be similar to elevation detector.
        # could define new frame with varying rotation for slewing antenna.
        fovDetector = GroundFieldOfViewDetector(topo, fov).withMaxCheck(5.0)
        self.assertEqual(topo, fovDetector.getFrame())
        self.assertEqual(fov, fovDetector.getFieldOfView())
        logger = EventsLogger()

        prop = KeplerianPropagator(orbit)
        prop.addEventDetector(logger.monitorDetector(fovDetector))
        prop.propagate(endDate)
        actual = logger.getLoggedEvents()

        # verify
        self.assertEquals(2, expected.size())
        self.assertEquals(2, actual.size())

        for i in range(0, 1):
            expectedDate = expected.get(i).getState().getDate()
            actualDate = actual.get(i).getState().getDate()
            # same event times to within 1s.
            self.assertAlmostEqual(expectedDate.durationFrom(actualDate), 0.0, delta=1.0)


if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(GroundFieldOfViewDetectorTest)
    ret = not unittest.TextTestRunner(verbosity=2).run(suite).wasSuccessful()
    sys.exit(ret)
