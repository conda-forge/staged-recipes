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

# Python orekit specifics
import orekit
orekit.initVM()

from orekit.pyhelpers import setup_orekit_curdir
setup_orekit_curdir()   # orekit-data.zip shall be in current dir

from org.orekit.propagation.events import EventsLogger
from org.orekit.propagation.events import NodeDetector
from org.hipparchus.ode.nonstiff import DormandPrince853Integrator
from org.hipparchus.util import FastMath
from org.orekit.frames import FramesFactory
from org.orekit.orbits import KeplerianOrbit
from org.orekit.orbits import PositionAngle
from org.orekit.propagation import SpacecraftState
from org.orekit.propagation.events.handlers import ContinueOnEvent
from org.orekit.propagation.numerical import NumericalPropagator
from org.orekit.time import AbsoluteDate
from org.orekit.time import TimeScalesFactory
from org.orekit.utils import Constants
from orekit import JArray_double

# Floats are needed to be specific in the orekit interface
a = 800000.0 + Constants.WGS84_EARTH_EQUATORIAL_RADIUS
e = 0.0001
i = FastMath.toRadians(98.0)
w = -90.0
raan = 0.0
v = 0.0

inertialFrame = FramesFactory.getEME2000()
initialDate = AbsoluteDate(2014, 1, 1, 0, 0, 0.0, TimeScalesFactory.getUTC())
finalDate = initialDate.shiftedBy(70*24*60*60.0)
initialOrbit = KeplerianOrbit(a, e, i, w, raan, v, PositionAngle.TRUE, inertialFrame, initialDate, Constants.WGS84_EARTH_MU)
initialState = SpacecraftState(initialOrbit, 1000.0)

tol = NumericalPropagator.tolerances(10.0, initialOrbit, initialOrbit.getType())

# Double array of doubles needs to be retyped to work
integrator = DormandPrince853Integrator(0.001, 1000.0, 
    JArray_double.cast_(tol[0]),
    JArray_double.cast_(tol[1]))

propagator = NumericalPropagator(integrator)
propagator.setInitialState(initialState)

# Define 2 instances of NodeDetector:
rawDetector = NodeDetector(1e-6, 
        initialState.getOrbit(), 
        initialState.getFrame()).withHandler(ContinueOnEvent().of_(NodeDetector))

logger1 = EventsLogger()
node1 = logger1.monitorDetector(rawDetector)
logger2 = EventsLogger()
node2 = logger2.monitorDetector(rawDetector)

propagator.addEventDetector(node1)
propagator.addEventDetector(node2)

# First propagation
propagator.setEphemerisMode()
propagator.propagate(finalDate)

assert 1998==logger1.getLoggedEvents().size()
assert 1998== logger2.getLoggedEvents().size();
logger1.clearLoggedEvents()
logger2.clearLoggedEvents()

postpro = propagator.getGeneratedEphemeris()

# Post-processing
postpro.addEventDetector(node1)
postpro.addEventDetector(node2)
postpro.propagate(finalDate)
assert 1998==logger1.getLoggedEvents().size()
assert 1998==logger2.getLoggedEvents().size()

print("NodeDetectorTest Successfully run")
