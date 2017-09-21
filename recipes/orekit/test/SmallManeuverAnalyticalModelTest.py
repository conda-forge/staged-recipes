# -*- coding: utf-8 -*-

"""

/* Copyright 2002-2015 CS Syst��mes d'Information
 * Licensed to CS Syst��mes d'Information (CS) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * CS licenses this file to You under the Apache License, Version 2.0
 * (the "License") you may not use this file except in compliance with
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

Python version translated from Java by Petrus Hyvönen, SSC 2015

 """
import orekit

orekit.initVM()
from orekit.pyhelpers import setup_orekit_curdir

setup_orekit_curdir()

from orekit import JArray_double, JArray

from org.orekit.forces.maneuvers import SmallManeuverAnalyticalModel, ConstantThrustManeuver

from org.hipparchus.geometry.euclidean.threed import Vector3D
from org.hipparchus.ode.nonstiff import DormandPrince853Integrator
from org.hipparchus.util import FastMath
from org.orekit.utils import Constants
from org.orekit.attitudes import LofOffset

from org.orekit.frames import FramesFactory
from org.orekit.frames import LOFType
from org.orekit.orbits import CircularOrbit
from org.orekit.orbits import KeplerianOrbit
from org.orekit.orbits import PositionAngle
from org.orekit.propagation import SpacecraftState
from org.orekit.propagation.numerical import NumericalPropagator
from org.orekit.time import AbsoluteDate
from org.orekit.time import DateComponents
from org.orekit.time import TimeComponents
from org.orekit.time import TimeScalesFactory
from org.orekit.utils import Constants
from org.orekit.utils import PVCoordinates

from math import radians

# from org.orekit.forces.maneuvers import getEphemeris

import unittest
import sys


class SmallManeuverAnalyticalModelTest(unittest.TestCase):
    def testLowEarthOrbit1(self):
        leo = CircularOrbit(7200000.0, -1.0e-5, 2.0e-4,
                            radians(98.0),
                            radians(123.456),
                            0.0, PositionAngle.MEAN,
                            FramesFactory.getEME2000(),
                            AbsoluteDate(DateComponents(2004, 1, 1),
                                         TimeComponents(23, 30, 00.000),
                                         TimeScalesFactory.getUTC()),
                            Constants.EIGEN5C_EARTH_MU)
        mass = 5600.0
        t0 = leo.getDate().shiftedBy(1000.0)
        dV = Vector3D(-0.01, 0.02, 0.03)
        f = 20.0
        isp = 315.0
        withoutManeuver = self.getEphemeris(leo, mass, t0, Vector3D.ZERO, f, isp)
        withManeuver = self.getEphemeris(leo, mass, t0, dV, f, isp)
        model = SmallManeuverAnalyticalModel(withoutManeuver.propagate(t0), dV, isp)

        self.assertEquals(t0.toString(), model.getDate().toString())

        t = withoutManeuver.getMinDate()
        while t.compareTo(withoutManeuver.getMaxDate()) < 0:
            pvWithout = withoutManeuver.getPVCoordinates(t, leo.getFrame())
            pvWith = withManeuver.getPVCoordinates(t, leo.getFrame())
            pvModel = model.apply(withoutManeuver.propagate(t)).getPVCoordinates(leo.getFrame())
            nominalDeltaP = PVCoordinates(pvWith, pvWithout).getPosition().getNorm()
            modelError = PVCoordinates(pvWith, pvModel).getPosition().getNorm()
            if t.compareTo(t0) < 0:
                # before maneuver, all positions should be equal
                self.assertEquals(0, nominalDeltaP, 1.0e-10)
                self.assertEquals(0, modelError, 1.0e-10)
            else:
                # after maneuver, model error should be less than 0.8m,
                # despite nominal deltaP exceeds 1 kilometer after less than 3 orbits
                if t.durationFrom(t0) > 0.1 * leo.getKeplerianPeriod():
                    self.assertTrue(modelError < 0.009 * nominalDeltaP)

                self.assertTrue(modelError < 0.8)

            t = t.shiftedBy(60.0)

    def testLowEarthOrbit2(self):

        leo = CircularOrbit(7200000.0, -1.0e-5, 2.0e-4,
                            radians(98.0),
                            radians(123.456),
                            0.0, PositionAngle.MEAN,
                            FramesFactory.getEME2000(),
                            AbsoluteDate(DateComponents(2004, 1, 1),
                                         TimeComponents(23, 30, 00.000),
                                         TimeScalesFactory.getUTC()),
                            Constants.EIGEN5C_EARTH_MU)
        mass = 5600.0
        t0 = leo.getDate().shiftedBy(1000.0)
        dV = Vector3D(-0.01, 0.02, 0.03)
        f = 20.0
        isp = 315.0
        withoutManeuver = self.getEphemeris(leo, mass, t0, Vector3D.ZERO, f, isp)
        withManeuver = self.getEphemeris(leo, mass, t0, dV, f, isp)
        model = SmallManeuverAnalyticalModel(withoutManeuver.propagate(t0), dV, isp)
        self.assertEquals(t0.toString(), model.getDate().toString())

        t = withoutManeuver.getMinDate()
        while t.compareTo(withoutManeuver.getMaxDate()) < 0:
            pvWithout = withoutManeuver.getPVCoordinates(t, leo.getFrame())
            pvWith = withManeuver.getPVCoordinates(t, leo.getFrame())
            pvModel = model.apply(withoutManeuver.propagate(t).getOrbit()).getPVCoordinates(leo.getFrame())
            nominalDeltaP = PVCoordinates(pvWith, pvWithout).getPosition().getNorm()
            modelError = PVCoordinates(pvWith, pvModel).getPosition().getNorm()
            if t.compareTo(t0) < 0:
                # before maneuver, all positions should be equal
                self.assertEquals(0, nominalDeltaP, 1.0e-10)
                self.assertEquals(0, modelError, 1.0e-10)
            else:
                # after maneuver, model error should be less than 0.8m,
                # despite nominal deltaP exceeds 1 kilometer after less than 3 orbits
                if t.durationFrom(t0) > 0.1 * leo.getKeplerianPeriod():
                    self.assertTrue(modelError < 0.009 * nominalDeltaP)

                self.assertTrue(modelError < 0.8)

            t = t.shiftedBy(60.0)

    def testEccentricOrbit(self):

        heo = KeplerianOrbit(90000000.0, 0.92, FastMath.toRadians(98.0),
                             radians(12.3456),
                             radians(123.456),
                             radians(1.23456), PositionAngle.MEAN,
                             FramesFactory.getEME2000(),
                             AbsoluteDate(DateComponents(2004, 1, 1),
                                          TimeComponents(23, 30, 00.000),
                                          TimeScalesFactory.getUTC()),
                             Constants.EIGEN5C_EARTH_MU)
        mass = 5600.0
        t0 = heo.getDate().shiftedBy(1000.0)
        dV = Vector3D(-0.01, 0.02, 0.03)
        f = 20.0
        isp = 315.0
        withoutManeuver = self.getEphemeris(heo, mass, t0, Vector3D.ZERO, f, isp)
        withManeuver = self.getEphemeris(heo, mass, t0, dV, f, isp)
        model = SmallManeuverAnalyticalModel(withoutManeuver.propagate(t0), dV, isp)

        self.assertEquals(t0.toString(), model.getDate().toString())

        t = withoutManeuver.getMinDate()
        while t.compareTo(withoutManeuver.getMaxDate()) < 0:
            pvWithout = withoutManeuver.getPVCoordinates(t, heo.getFrame())
            pvWith = withManeuver.getPVCoordinates(t, heo.getFrame())
            pvModel = model.apply(withoutManeuver.propagate(t)).getPVCoordinates(heo.getFrame())
            nominalDeltaP = PVCoordinates(pvWith, pvWithout).getPosition().getNorm()
            modelError = PVCoordinates(pvWith, pvModel).getPosition().getNorm()
            if t.compareTo(t0) < 0:
                # before maneuver, all positions should be equal
                self.assertEquals(0, nominalDeltaP, 1.0e-10)
                self.assertEquals(0, modelError, 1.0e-10)
            else:
                # after maneuver, model error should be less than 1700m,
                # despite nominal deltaP exceeds 300 kilometers at perigee, after 3 orbits
                if t.durationFrom(t0) > 0.01 * heo.getKeplerianPeriod():
                    self.assertTrue(modelError < 0.005 * nominalDeltaP)

                self.assertTrue(modelError < 1700)
            t = t.shiftedBy(600.0)

    # Jacobian test removed due to the large amount of manual work currently with 2D java arrays

    def getEphemeris(self, orbit, mass, t0, dV, f, isp):

        law = LofOffset(orbit.getFrame(), LOFType.LVLH)
        initialState = SpacecraftState(orbit, law.getAttitude(orbit, orbit.getDate(), orbit.getFrame()), mass)

        # set up numerical propagator
        dP = 1.0
        tolerances = NumericalPropagator.tolerances(dP, orbit, orbit.getType())

        integrator = DormandPrince853Integrator(0.001, 1000.0, JArray_double.cast_(tolerances[0]),
                                                JArray_double.cast_(tolerances[1]))

        integrator.setInitialStepSize(orbit.getKeplerianPeriod() / 100.0)
        propagator = NumericalPropagator(integrator)
        propagator.setOrbitType(orbit.getType())
        propagator.setInitialState(initialState)
        propagator.setAttitudeProvider(law)

        if dV.getNorm() > 1.0e-6:
            # set up maneuver
            vExhaust = Constants.G0_STANDARD_GRAVITY * isp
            dt = -(mass * vExhaust / f) * FastMath.expm1(-dV.getNorm() / vExhaust)
            maneuver = ConstantThrustManeuver(t0, dt, f, isp, dV.normalize())
            propagator.addForceModel(maneuver)

        propagator.setEphemerisMode()
        propagator.propagate(t0.shiftedBy(5 * orbit.getKeplerianPeriod()))
        return propagator.getGeneratedEphemeris()


if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(SmallManeuverAnalyticalModelTest)
    ret = not unittest.TextTestRunner(verbosity=2).run(suite).wasSuccessful()
    sys.exit(ret)
