#!/bin/sh

rm -rf build
mkdir build
cd build

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

if [[ "${target_platform}" == linux-* ]]; then
    export ICUB_MAIN_ON_LINUX=ON
else
    export ICUB_MAIN_ON_LINUX=OFF
fi

cmake ${CMAKE_ARGS} -GNinja .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS:BOOL=ON \
      -DBUILD_TESTING:BOOL=ON \
      -DENABLE_icubmod_cartesiancontrollerserver:BOOL=ON \
      -DENABLE_icubmod_cartesiancontrollerclient:BOOL=ON \
      -DENABLE_icubmod_gazecontrollerclient:BOOL=ON \
      -DENABLE_icubmod_serial:BOOL=ON \
      -DENABLE_icubmod_serialport:BOOL=ON \
      -DENABLE_icubmod_skinWrapper:BOOL=ON \
      -DENABLE_icubmod_dragonfly2:BOOL=${ICUB_MAIN_ON_LINUX} \
      -DENABLE_icubmod_portaudio:BOOL=ON \
      -DENABLE_icubmod_sharedcan:BOOL=ON \
      -DENABLE_icubmod_bcbBattery:BOOL=ON \
      -DENABLE_icubmod_canmotioncontrol:BOOL=ON \
      -DENABLE_icubmod_canBusAnalogSensor:BOOL=ON \
      -DENABLE_icubmod_canBusInertialMTB:BOOL=ON \
      -DENABLE_icubmod_canBusSkin:BOOL=ON \
      -DENABLE_icubmod_canBusFtSensor:BOOL=ON \
      -DENABLE_icubmod_canBusVirtualAnalogSensor:BOOL=ON \
      -DENABLE_icubmod_cfw2can:BOOL=OFF \
      -DENABLE_icubmod_ecan:BOOL=OFF \
      -DENABLE_icubmod_embObjBattery:BOOL=ON \
      -DENABLE_icubmod_embObjFTsensor:BOOL=ON \
      -DENABLE_icubmod_embObjMultipleFTsensors:BOOL=ON \
      -DENABLE_icubmod_embObjIMU:BOOL=ON \
      -DENABLE_icubmod_embObjMais:BOOL=ON \
      -DENABLE_icubmod_embObjMotionControl:BOOL=ON \
      -DENABLE_icubmod_embObjSkin:BOOL=ON \
      -DENABLE_icubmod_embObjVirtualAnalogSensor:BOOL=ON \
      -DENABLE_icubmod_parametricCalibrator:BOOL=ON \
      -DENABLE_icubmod_parametricCalibratorEth:BOOL=ON \
      -DENABLE_icubmod_embObjPOS:BOOL=ON \
      -DENABLE_icubmod_xsensmtx:BOOL=ON \
      -DENABLE_icubmod_socketcan:BOOL=${ICUB_MAIN_ON_LINUX} \
      -DICUB_USE_icub_firmware_shared:BOOL=ON \
      -DICUBMAIN_COMPILE_SIMULATORS:BOOL=OFF \
      -DICUB_COMPILE_BINDINGS:BOOL=OFF \
      ..

cmake --build . --config Release

if [[ ("${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "") ]]; then
  ctest --output-on-failure  -C Release 
fi

cmake --build . --config Release --target install
