"""Checks of the installed openmm-lbm: its plugins are loaded, and a short run with particles in a moving fluid
gives the same fluid on the Reference and OpenCL (pocl on the CPU) platforms."""

import openmm as mm
import openmm.unit as unit
from openmmlbm import LBMForce

# The CUDA plugins (of OpenMM and of openmm-lbm) cannot be loaded without the NVIDIA driver library, which a
# build machine does not have; any other failure of an openmm-lbm plugin is an error.
failures = [f for f in mm.Platform.getPluginLoadFailures() if 'LBM' in f and 'libcuda' not in f]
assert not failures, failures

platforms = [mm.Platform.getPlatform(i).getName() for i in range(mm.Platform.getNumPlatforms())]
print('Platforms:', platforms)


def run(platform, properties):
    box = 4.0
    system = mm.System()
    system.setDefaultPeriodicBoxVectors(mm.Vec3(box, 0, 0), mm.Vec3(0, box, 0), mm.Vec3(0, 0, box))
    force = LBMForce()
    force.setGridSize(8, 8, 8)
    force.setTemperature(0*unit.kelvin)
    force.setInitialFluidVelocity(mm.Vec3(0.1, -0.05, 0.02)*unit.nanometer/unit.picosecond)
    for i in range(10):
        system.addParticle(100.0)
        force.addParticle(i)
    system.addForce(force)
    context = mm.Context(system, mm.VerletIntegrator(0.01), mm.Platform.getPlatformByName(platform), properties)
    context.setPositions([mm.Vec3(0.37*i, 0.53*i + 0.1, 0.71*i + 0.2) for i in range(10)])
    context.setVelocities([mm.Vec3(0.2, 0.1*(i % 3), -0.1) for i in range(10)])
    context.getIntegrator().step(20)
    density, velocity = force.getFluidFields(context)
    density = [d.value_in_unit(unit.dalton/unit.nanometer**3) for d in density]
    velocity = [[c.value_in_unit(unit.nanometer/unit.picosecond) for c in v] for v in velocity]
    return density, velocity


reference = run('Reference', {})
print('Reference: mean density %.6f Da/nm^3' % (sum(reference[0])/len(reference[0])))
assert 'OpenCL' in platforms, 'the OpenCL platform (pocl) is not available'
opencl = run('OpenCL', {'Precision': 'double'})
density_error = max(abs(a - b) for a, b in zip(reference[0], opencl[0]))
velocity_error = max(abs(a - b) for u, w in zip(reference[1], opencl[1]) for a, b in zip(u, w))
print('OpenCL - Reference: density %.3g Da/nm^3, velocity %.3g nm/ps' % (density_error, velocity_error))
assert density_error < 1e-6*602.214 and velocity_error < 1e-8
print('openmm-lbm: Reference and OpenCL agree')
