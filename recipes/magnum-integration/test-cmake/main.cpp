#include <Magnum/EigenIntegration/Integration.h>
#include <Magnum/Math/Vector3.h>

#include <Eigen/Core>

int main() {
    Eigen::Vector3f eigenVector{1.0f, 2.0f, 3.0f};
    Magnum::Vector3 magnumVector =
        Magnum::EigenIntegration::cast<Magnum::Vector3>(eigenVector);
    return magnumVector.x() == 1.0f &&
                   magnumVector.y() == 2.0f &&
                   magnumVector.z() == 3.0f
               ? 0
               : 1;
}
