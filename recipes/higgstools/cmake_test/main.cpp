#include <Higgs/Bounds.hpp>
#include <Higgs/Predictions.hpp>
#include <Higgs/Signals.hpp>
#include <iostream>

int main() {
    namespace HP = Higgs::predictions;
    auto pred = HP::Predictions{};
    auto &h = pred.addParticle(
        HP::BsmParticle{"h", HP::ECharge::neutral, HP::CP::even});
    h.setMass(125.09);
    HP::effectiveCouplingInput(h, HP::smLikeEffCouplings);
    const double xs = h.cxn(HP::Collider::LHC13, HP::Production::ggH);
    std::cout << "SM-like ggH cross section at 13 TeV: " << xs << " pb\n";
    return (xs > 45 && xs < 52) ? 0 : 1;
}
