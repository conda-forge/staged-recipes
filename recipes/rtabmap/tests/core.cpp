#include <rtabmap/core/Transform.h>
#include <rtabmap/core/Version.h>

#include <iostream>

#ifndef RTABMAP_APRILTAG
#error "RTAB-Map was not built with AprilTag support"
#endif
#ifndef RTABMAP_CERES
#error "RTAB-Map was not built with Ceres support"
#endif
#ifndef RTABMAP_OCTOMAP
#error "RTAB-Map was not built with OctoMap support"
#endif
#ifndef RTABMAP_PDAL
#error "RTAB-Map was not built with PDAL support"
#endif
#ifndef RTABMAP_REALSENSE2
#error "RTAB-Map was not built with RealSense2 support"
#endif
#ifndef _WIN32
#ifndef RTABMAP_DC1394
#error "RTAB-Map was not built with dc1394 support"
#endif
#endif

#ifdef RTABMAP_G2O
#error "RTAB-Map unexpectedly enabled g2o"
#endif
#ifdef RTABMAP_GTSAM
#error "RTAB-Map unexpectedly enabled GTSAM"
#endif
#ifdef RTABMAP_MADGWICK
#error "RTAB-Map unexpectedly included GPL Madgwick code"
#endif
#ifdef RTABMAP_OPENGV
#error "RTAB-Map unexpectedly enabled OpenGV"
#endif
#ifdef RTABMAP_ORB_OCTREE
#error "RTAB-Map unexpectedly included GPL ORB OcTree code"
#endif
#ifdef RTABMAP_PYTHON
#error "RTAB-Map unexpectedly embedded Python"
#endif
#ifdef RTABMAP_TORO
#error "RTAB-Map unexpectedly included noncommercial TORO code"
#endif
#ifdef RTABMAP_VERTIGO
#error "RTAB-Map unexpectedly included GPL Vertigo code"
#endif

int main()
{
    const auto identity = rtabmap::Transform::getIdentity();
    if (!identity.isIdentity()) {
        return 1;
    }
    std::cout << RTABMAP_VERSION << '\n';
    return 0;
}
