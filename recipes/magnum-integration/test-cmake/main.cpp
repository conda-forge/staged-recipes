#include <Magnum/EigenIntegration/Integration.h>
#include <Magnum/Math/Vector3.h>

#include <Eigen/Core>

int main() {
    Eigen::Vector3f eigenVector{1.0f, 2.0f, 3.0f};
    Magnum::Vector3 magnumVector{eigenVector};
    Eigen::Vector3f roundTrip =
        Magnum::EigenIntegration::cast<Eigen::Vector3f>(magnumVector);
    return roundTrip.x() == 1.0f &&
                   roundTrip.y() == 2.0f &&
                   roundTrip.z() == 3.0f
               ? 0
               : 1;
}
