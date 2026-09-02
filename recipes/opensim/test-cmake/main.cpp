#include <OpenSim/OpenSim.h>

#include <cmath>

int main() {
    OpenSim::Model model;
    model.setGravity(SimTK::Vec3(0));
    auto* body = new OpenSim::Body(
            "body", 2.0, SimTK::Vec3(0), SimTK::Inertia(1));
    auto* joint = new OpenSim::SliderJoint("slider", model.getGround(), *body);
    model.addBody(body);
    model.addJoint(joint);
    auto& coordinate = joint->updCoordinate();
    SimTK::State& state = model.initSystem();
    coordinate.setValue(state, 0.25);
    model.realizePosition(state);
    return std::abs(coordinate.getValue(state) - 0.25) < 1e-12 ? 0 : 1;
}
