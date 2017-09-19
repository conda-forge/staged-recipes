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
setup_orekit_curdir()   # orekit-data.zip shall be in current dir
#from math import abs

from org.hipparchus.util import FastMath
from org.orekit.bodies import CelestialBodyFactory
from org.orekit.bodies import OneAxisEllipsoid
from org.orekit.frames import FramesFactory
from org.orekit.orbits import KeplerianOrbit
from org.orekit.orbits import PositionAngle
from org.orekit.propagation import SpacecraftState
from org.orekit.propagation.analytical import KeplerianPropagator
from org.orekit.propagation.events.handlers import StopOnEvent
from org.orekit.time import AbsoluteDate
from org.orekit.time import TimeScalesFactory
from org.orekit.propagation.events import AltitudeDetector

EME2000 = FramesFactory.getEME2000()
initialDate = AbsoluteDate(2009,1,1,TimeScalesFactory.getUTC())
a = 8000000.0
e = 0.1
earthRadius = 6378137.0
earthF = 1.0 / 298.257223563
apogee = a*(1+e)
alt = apogee - earthRadius - 500

#// initial state is at apogee
initialOrbit = KeplerianOrbit(a,e,0.0,0.0,0.0,FastMath.PI,PositionAngle.MEAN,EME2000,
                                                      initialDate,CelestialBodyFactory.getEarth().getGM())
initialState = SpacecraftState(initialOrbit)
kepPropagator = KeplerianPropagator(initialOrbit)
altDetector = AltitudeDetector(alt, 
    OneAxisEllipsoid(earthRadius, earthF, EME2000)).withHandler(StopOnEvent().of_(AltitudeDetector))

# altitudeDetector should stop propagation upon reaching required altitude
kepPropagator.addEventDetector(altDetector)

#// propagation to the future
finalState = kepPropagator.propagate(initialDate.shiftedBy(1000.0))
assert abs(finalState.getPVCoordinates().getPosition().getNorm()-earthRadius -alt)<1e-5
assert abs(44.079 - finalState.getDate().durationFrom(initialDate))< 1.0e-3

#// propagation to the past
kepPropagator.resetInitialState(initialState)
finalState = kepPropagator.propagate(initialDate.shiftedBy(-1000.0))
assert abs(finalState.getPVCoordinates().getPosition().getNorm()-earthRadius - alt)< 1e-5
assert abs(-44.079 - finalState.getDate().durationFrom(initialDate))< 1.0e-3

print("AltitudeDetectorTest successfully run")
