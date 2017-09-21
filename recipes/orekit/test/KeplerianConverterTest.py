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

from org.orekit.frames import FramesFactory
from org.orekit.propagation.analytical import KeplerianPropagator
from org.orekit.time import AbsoluteDate
from org.hipparchus.geometry.euclidean.threed import Vector3D
from org.orekit.orbits import EquinoctialOrbit
from org.orekit.orbits import Orbit
from org.orekit.orbits import OrbitType
from org.orekit.orbits import PositionAngle
from org.orekit.utils import PVCoordinates
from org.orekit.propagation.conversion import FiniteDifferencePropagatorConverter
from org.orekit.propagation.conversion import KeplerianPropagatorBuilder
import unittest
import sys
from java.util import Arrays


class KeplerianConverterTest(unittest.TestCase):
    
    position = Vector3D(7.0e6, 1.0e6, 4.0e6)
    velocity = Vector3D(-500.0, 8000.0, 1000.0)
    mu = 3.9860047e14

    def checkFit(self, orbit,
                 duration,
                 stepSize,
                 threshold,
                 positionOnly,
                 expectedRMS,
                 *args):
    
        p =  KeplerianPropagator(orbit)
        
        sample = []
        dt = 0.0
        while dt < duration:
            sample.append(p.propagate(orbit.getDate().shiftedBy(dt)))
            dt += stepSize
        

        builder = KeplerianPropagatorBuilder(OrbitType.KEPLERIAN.convertType(orbit),
                                                                   PositionAngle.MEAN,
                                                                   1.0)

        fitter = FiniteDifferencePropagatorConverter(builder, threshold, 1000)

        fitter.convert(Arrays.asList(sample), positionOnly, [])
        
        self.assertAlmostEqual(fitter.getRMS(), 0.01 * expectedRMS, delta=expectedRMS)

        prop = fitter.getAdaptedPropagator()  #(KeplerianPropagator)
        fitted = prop.getInitialState().getOrbit()

        eps = 1.0e-12
        self.assertAlmostEqual(orbit.getPVCoordinates().getPosition().getX(),
                            fitted.getPVCoordinates().getPosition().getX(), 
                            delta = eps * orbit.getPVCoordinates().getPosition().getX())
        self.assertAlmostEqual(orbit.getPVCoordinates().getPosition().getY(),
                            fitted.getPVCoordinates().getPosition().getY(),
                            delta = eps * orbit.getPVCoordinates().getPosition().getY())
        self.assertAlmostEqual(orbit.getPVCoordinates().getPosition().getZ(),
                            fitted.getPVCoordinates().getPosition().getZ(),
                            delta = eps * orbit.getPVCoordinates().getPosition().getZ())

        self.assertAlmostEqual(orbit.getPVCoordinates().getVelocity().getX(),
                            fitted.getPVCoordinates().getVelocity().getX(),
                            delta = -eps * orbit.getPVCoordinates().getVelocity().getX())
        self.assertAlmostEqual(orbit.getPVCoordinates().getVelocity().getY(),
                            fitted.getPVCoordinates().getVelocity().getY(),
                            delta = eps * orbit.getPVCoordinates().getVelocity().getY())
        self.assertAlmostEqual(orbit.getPVCoordinates().getVelocity().getZ(),
                            fitted.getPVCoordinates().getVelocity().getZ(),
                            delta = eps * orbit.getPVCoordinates().getVelocity().getZ())

    def testConversionPositionVelocity(self):
        self.checkFit(self.orbit, 86400, 300, 1.0e-3, False, 1.89e-8)
        
    def testConversionPositionOnly(self):
        self.checkFit(self.orbit, 86400, 300, 1.0e-3, True, 2.90e-8)
        
#    #@Test(expected = OrekitException.class)
#    def testConversionWithFreeParameter(self): 
#        self.checkFit(self.orbit, 86400, 300, 1.0e-3, True, 2.65e-8, "toto");
    
    def setUp(self):
        setup_orekit_curdir()

        self.initDate = AbsoluteDate.J2000_EPOCH.shiftedBy(584.)
        self.orbit = EquinoctialOrbit(PVCoordinates(self.position, self.velocity),
                                     FramesFactory.getEME2000(), self.initDate, self.mu)


if __name__ == '__main__':

    suite = unittest.TestLoader().loadTestsFromTestCase(KeplerianConverterTest)
    ret = not unittest.TextTestRunner(verbosity=2).run(suite).wasSuccessful()
    sys.exit(ret)
