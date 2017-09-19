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

#Python orekit specifics
import orekit
orekit.initVM()
from orekit.pyhelpers import setup_orekit_curdir
setup_orekit_curdir()

from org.hipparchus.geometry.euclidean.threed import Vector3D
from org.hipparchus.util import FastMath
from org.orekit.attitudes import LofOffset
from org.orekit.frames import FramesFactory
from org.orekit.frames import LOFType
from org.orekit.orbits import KeplerianOrbit
from org.orekit.orbits import PositionAngle
from org.orekit.propagation.analytical import KeplerianPropagator
from org.orekit.propagation.events import NodeDetector
from org.orekit.time import AbsoluteDate
from org.orekit.time import DateComponents
from org.orekit.time import TimeComponents
from org.orekit.time import TimeScalesFactory
from org.orekit.forces.maneuvers import ImpulseManeuver
import unittest
import sys
import math

class ImpulseManeuverTest(unittest.TestCase):
    
    def testInclinationManeuver(self):
        initialOrbit = KeplerianOrbit(24532000.0,
                                      0.72,
                                      0.3,
                                      FastMath.PI,
                                      0.4,
                                      2.0,
                                   PositionAngle.MEAN,
                                   FramesFactory.getEME2000(),
                                   AbsoluteDate(DateComponents(2008, 6, 23),
                                                    TimeComponents(14, 18, 37.0),
                                                    TimeScalesFactory.getUTC()),
                                   3.986004415e14)

        a  = initialOrbit.getA()
        e  = initialOrbit.getE()
        i  = initialOrbit.getI()
        mu = initialOrbit.getMu()
        vApo = math.sqrt(mu * (1 - e) / (a * (1 + e)))
        dv = 0.99 * math.tan(i) * vApo

        propagator = KeplerianPropagator(initialOrbit,
                                         LofOffset(initialOrbit.getFrame(), LOFType.VVLH))

        det = ImpulseManeuver(NodeDetector(initialOrbit, 
                                          FramesFactory.getEME2000() ),
                                            Vector3D(dv, Vector3D.PLUS_J), 400.0)
        det = det.of_(NodeDetector)
        
        propagator.addEventDetector(det)
                                        
        propagated = propagator.propagate(initialOrbit.getDate().shiftedBy(8000.0))

        self.assertAlmostEqual(0.0028257, propagated.getI(), delta=1.0e-6)
        
if __name__ == '__main__':
    #unittest.main()
    
    suite = unittest.TestLoader().loadTestsFromTestCase(ImpulseManeuverTest)
    ret = not unittest.TextTestRunner(verbosity=2).run(suite).wasSuccessful()
    sys.exit(ret)

