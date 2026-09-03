#include <OpenSim/OpenSim.h>
#include <OpenSim/Moco/osimMoco.h>

#include <cmath>
#include <cstdio>
#include <iostream>
#include <vector>

namespace {

bool near(double actual, double expected) {
    return std::abs(actual - expected) < 1e-10;
}

} // namespace

int main() {
    // Exercise Array<bool> from outside osimCommon. MSVC 17.14 otherwise
    // looked for the private BoolLike helper as an unexported DLL symbol.
    OpenSim::Array<bool> flags(false, 2);
    flags[0] = true;
    if (!flags[0] || flags[1]) {
        std::cerr << "Array<bool> storage failed\n";
        return 1;
    }

    OpenSim::Model model;
    model.setGravity(SimTK::Vec3(0, -10, 0));
    auto* body = new OpenSim::Body(
            "body", 2.0, SimTK::Vec3(0), SimTK::Inertia(1));
    auto* joint = new OpenSim::SliderJoint("slider", model.getGround(), *body);
    model.addBody(body);
    model.addJoint(joint);
    auto& coordinate = joint->updCoordinate();
    coordinate.setName("position");

    auto* spring1 = new OpenSim::SpringGeneralizedForce("position");
    spring1->setName("spring1");
    spring1->setStiffness(20.0);
    spring1->setRestLength(0.05);
    spring1->setViscosity(2.0);
    model.addForce(spring1);

    auto* spring2 = new OpenSim::SpringGeneralizedForce("position");
    spring2->setName("spring2");
    spring2->setStiffness(12.0);
    spring2->setRestLength(-0.25);
    spring2->setViscosity(0.5);
    model.addForce(spring2);

    SimTK::State& state = model.initSystem();
    coordinate.setValue(state, 0.25);
    coordinate.setSpeedValue(state, 0.1);
    model.realizeDynamics(state);

    SimTK::Array_<SimTK::ForceIndex> forceIndexes;
    forceIndexes.push_back(model.getGravityForce().getForceIndex());
    forceIndexes.push_back(spring1->getForceIndex());
    forceIndexes.push_back(spring2->getForceIndex());

    SimTK::Vector_<SimTK::SpatialVec> bodyForces;
    SimTK::Vector mobilityForces;
    model.calcForceContributionsSum(
            state, forceIndexes, bodyForces, mobilityForces);

    // Gravity contributes -20 N along y to the 2 kg body. The two springs
    // contribute -4.2 N and -6.05 N along the slider mobility.
    const bool correctSizes = bodyForces.size() == 2 && mobilityForces.size() == 1;
    const bool correctBodyForce = near(bodyForces[1][1][0], 0.0) &&
            near(bodyForces[1][1][1], -20.0) &&
            near(bodyForces[1][1][2], 0.0);
    const bool correctMobilityForce = near(mobilityForces[0], -10.25);
    if (!correctSizes || !correctBodyForce || !correctMobilityForce) {
        std::cerr << "unexpected summed forces: body=" << bodyForces
                  << " mobility=" << mobilityForces << '\n';
        return 1;
    }

    // Keep the disabled spring in the requested index list. Simbody's native
    // 3.8 implementation skips disabled forces, and the 3.7 fallback must
    // preserve that behavior while still summing the other two forces.
    spring2->setAppliesForce(state, false);
    model.realizeDynamics(state);
    model.calcForceContributionsSum(
            state, forceIndexes, bodyForces, mobilityForces);
    if (!near(bodyForces[1][1][1], -20.0) ||
            !near(mobilityForces[0], -4.2)) {
        std::cerr << "disabled force was not skipped: body=" << bodyForces
                  << " mobility=" << mobilityForces << '\n';
        return 1;
    }

    // Exercise the Simbody-3.7-compatible XML precision path. Six-digit
    // serialization would fail these checks by several orders of magnitude.
    state.setTime(0.123456789012);
    coordinate.setValue(state, 0.234567890123);
    std::vector<SimTK::State> trajectory{state};
    const char* statesFile = "precision-roundtrip.ostates";
    OpenSim::StatesDocument document(model, trajectory, "precision test", 12);
    document.serialize(statesFile);
    OpenSim::StatesDocument loadedDocument(statesFile);
    std::vector<SimTK::State> loadedTrajectory;
    loadedDocument.deserialize(model, loadedTrajectory);
    std::remove(statesFile);
    if (loadedDocument.getPrecision() != 12 || loadedTrajectory.size() != 1 ||
            !near(loadedTrajectory[0].getTime(), state.getTime()) ||
            !near(coordinate.getValue(loadedTrajectory[0]),
                    coordinate.getValue(state))) {
        std::cerr << "StatesDocument precision round-trip failed\n";
        return 1;
    }

    // Exercise the upstream constrained-Moco case through Bordalba state
    // projection. This reaches the 3.7 fallback that pads acceleration-only
    // constraint multipliers before calling multiplyByGTranspose().
    OpenSim::Model constrainedModel =
            OpenSim::ModelFactory::createPlanarPointMass();
    constrainedModel.set_gravity(SimTK::Vec3(0));
    auto* constraint = new OpenSim::CoordinateCouplerConstraint();
    OpenSim::Array<std::string> independentCoordinates;
    independentCoordinates.append("tx");
    constraint->setIndependentCoordinateNames(independentCoordinates);
    constraint->setDependentCoordinateName("ty");
    constraint->setFunction(OpenSim::LinearFunction(1.0, 0.0));
    constrainedModel.addConstraint(constraint);
    constrainedModel.finalizeConnections();

    OpenSim::MocoStudy study;
    auto& problem = study.updProblem();
    problem.setModelAsCopy(constrainedModel);
    problem.setTimeBounds(0, 1);
    problem.setStateInfo("/jointset/tx/tx/value", {-5, 5}, 0, 3);
    problem.setStateInfo("/jointset/tx/tx/speed", {-5, 5}, 0, 0);
    problem.setControlInfo("/forceset/force_x", 0.5);
    problem.addGoal<OpenSim::MocoControlGoal>();

    auto& solver = study.initCasADiSolver();
    solver.set_num_mesh_intervals(5);
    solver.set_parallel(0);
    solver.set_verbosity(0);
    solver.set_multibody_dynamics_mode("explicit");
    solver.set_transcription_scheme("hermite-simpson");
    solver.set_kinematic_constraint_method("Bordalba2023");
    solver.set_enforce_constraint_derivatives(true);
    const OpenSim::MocoSolution solution = study.solve();
    if (!solution.success()) {
        std::cerr << "constrained Moco solve failed\n";
        return 1;
    }
    const SimTK::Matrix lambda = solution.getMultiplier("lambda_cid2_p0");
    const SimTK::Matrix forceX = solution.getControl("/forceset/force_x");
    const SimTK::Matrix forceY = solution.getControl("/forceset/force_y");
    if ((lambda - 0.5 * (forceX - forceY)).norm() > 1e-5) {
        std::cerr << "constraint multiplier projection mismatch\n";
        return 1;
    }
    return 0;
}
