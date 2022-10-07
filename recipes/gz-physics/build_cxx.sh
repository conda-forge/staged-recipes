#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} .. \
      -G "Ninja" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=True

cmake --build . --config Release ${NUM_PARALLEL}
cmake --build . --config Release --target install ${NUM_PARALLEL}

if [ ${target_platform} != "linux-ppc64le" ]; then
  # Remove test that fail on arm64: https://github.com/ignitionrobotics/ign-physics/issues/70
  # Remove test that fail on macOS: https://github.com/conda-forge/libignition-physics-feedstock/issues/13
  # Remove test INTEGRATION_ExamplesBuild_TEST that fails on multiple platforms: https://github.com/conda-forge/libignition-physics-feedstock/pull/14
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  ctest --output-on-failure -C Release -E "INTEGRATION_FrameSemantics2d|INTEGRATION_JointTypes2f|UNIT_Collisions_TEST|UNIT_EntityManagement_TEST|UNIT_JointFeatures_TEST|UNIT_LinkFeatures_TEST|UNIT_SDFFeatures_TEST|UNIT_SimulationFeatures_TEST|INTEGRATION_ExamplesBuild_TEST|UNIT_WorldFeatures_TEST|UNIT_ShapeFeatures_TEST|UNIT_FreeGroupFeatures_TEST|UNIT_KinematicsFeatures_TEST|PERFORMANCE"
fi
fi
