import glob
import json
import math
import os
from pathlib import Path

import opensim as osim


# Exercise the Python bindings and the system Simbody-backed dynamics path.
assert osim.GetVersion().startswith("4.5.2")
sample_c3d = Path(osim.__file__).parent / "tests" / "walking2.c3d"
c3d_tables = osim.C3DFileAdapter().read(str(sample_c3d))
assert sorted(c3d_tables.keys()) == ["analog", "forces", "markers"]
model = osim.Model()
model.setName("conda_forge_smoke")
model.set_gravity(osim.Vec3(0))
body = osim.Body("body", 2.0, osim.Vec3(0), osim.Inertia(1))
joint = osim.SliderJoint("slider", model.getGround(), body)
coordinate = joint.updCoordinate()
coordinate.setName("position")
model.addBody(body)
model.addJoint(joint)
state = model.initSystem()
coordinate.setValue(state, 0.25)
model.realizePosition(state)
assert math.isclose(coordinate.getValue(state), 0.25, abs_tol=1e-12)

# Solve a small optimal-control problem through Moco, CasADi, and Ipopt.
moco_model = osim.Model()
moco_model.set_gravity(osim.Vec3(0))
moco_body = osim.Body("body", 2.0, osim.Vec3(0), osim.Inertia(0))
moco_model.addComponent(moco_body)
moco_joint = osim.SliderJoint("slider", moco_model.getGround(), moco_body)
moco_joint.updCoordinate().setName("position")
moco_model.addComponent(moco_joint)
actuator = osim.CoordinateActuator()
actuator.setCoordinate(moco_joint.updCoordinate())
actuator.setName("actuator")
actuator.setOptimalForce(1)
moco_model.addComponent(actuator)
moco_model.finalizeConnections()

study = osim.MocoStudy()
problem = study.updProblem()
problem.setModel(moco_model)
problem.setTimeBounds(osim.MocoInitialBounds(0), osim.MocoFinalBounds(0, 5))
problem.setStateInfo(
    "/slider/position/value",
    osim.MocoBounds(-5, 5),
    osim.MocoInitialBounds(0),
    osim.MocoFinalBounds(1),
)
problem.setStateInfo("/slider/position/speed", [-50, 50], [0], [0])
problem.setControlInfo("/actuator", osim.MocoBounds(-50, 50))
problem.addGoal(osim.MocoFinalTimeGoal())
solver = study.initCasADiSolver()
solver.set_num_mesh_intervals(5)
solver.set_parallel(0)
solver.set_verbosity(0)
solution = study.solve()
assert solution.success()
assert 0 < solution.getFinalTime() < 1


# Assert that upstream's dependency-copying paths stayed disabled. Paths in
# this manifest belong only to the opensim package, not its dependencies.
prefix = Path(os.environ["PREFIX"])
metadata_files = glob.glob(str(prefix / "conda-meta" / "opensim-*.json"))
assert len(metadata_files) == 1, metadata_files
with open(metadata_files[0], encoding="utf-8") as handle:
    payload = {path.replace("\\", "/").lower() for path in json.load(handle)["files"]}

config_candidates = (
    prefix / "lib" / "cmake" / "OpenSim" / "OpenSimConfig.cmake",
    prefix / "Library" / "lib" / "cmake" / "OpenSim" / "OpenSimConfig.cmake",
)
config_file = next((path for path in config_candidates if path.is_file()), None)
assert config_file is not None, config_candidates
config_text = config_file.read_text(encoding="utf-8")
assert "find_dependency(Simbody 3.7)" in config_text
cmake_metadata = "\n".join(
    path.read_text(encoding="utf-8") for path in config_file.parent.glob("*.cmake")
)
for build_path_marker in (
    "host_env_placehold",
    "/bld/rattler-build_",
    "/conda-bld/",
    "\\conda-bld\\",
):
    assert build_path_marker not in cmake_metadata

forbidden_parts = (
    "/include/casadi/",
    "/include/coin/",
    "/include/coin-or/",
    "/include/docopt/",
    "/include/ezc3d/",
    "/include/simbody/",
    "/include/spdlog/",
    "/lib/cmake/casadi/",
    "/lib/cmake/docopt/",
    "/lib/cmake/ezc3d/",
    "/lib/cmake/simbody/",
    "/lib/cmake/spdlog/",
    "/lib/pkgconfig/ipopt.pc",
    "/sdk/casadi/",
    "/sdk/ezc3d/",
    "/sdk/ipopt/",
    "/sdk/simbody/",
    "/sdk/spdlog/",
)
forbidden_library_names = (
    "blas",
    "casadi",
    "docopt",
    "ezc3d",
    "freeglut",
    "ipopt",
    "lapack",
    "simtkcommon",
    "simtkmath",
    "simtksimbody",
    "spdlog",
)
unexpected = sorted(
    path
    for path in payload
    if any(part in f"/{path}" for part in forbidden_parts)
    or (
        (
            Path(path).suffix.lower() in {".a", ".dll", ".dylib", ".lib", ".so"}
            or ".so." in Path(path).name.lower()
        )
        and any(name in Path(path).name.lower() for name in forbidden_library_names)
    )
)
assert not unexpected, f"copied dependency payload: {unexpected}"
assert not any("osimdocopt" in path for path in payload), "bundled docopt was built"
assert any("osimlepton" in path for path in payload), "retained Lepton library missing"
assert any(path.endswith("opensim/__init__.py") for path in payload)
