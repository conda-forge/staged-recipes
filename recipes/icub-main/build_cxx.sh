#!/bin/sh

rm -rf build
mkdir build
cd build

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
      -DENABLE_icubmod_skinWrapper:BOOL=ON \
      -DENABLE_icubmod_dragonfly2:BOOL=${ICUB_MAIN_ON_LINUX} \
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
      -DENABLE_icubmod_parametricCalibrator:BOOL=ON \
      -DENABLE_icubmod_parametricCalibratorEth:BOOL=ON \
      -DENABLE_icubmod_embObjPOS:BOOL=ON \
      -DENABLE_icubmod_xsensmtx:BOOL=ON \
      -DENABLE_icubmod_socketcan:BOOL=${ICUB_MAIN_ON_LINUX} \
      -DICUB_USE_icub_firmware_shared:BOOL=ON \
      -DICUB_COMPILE_BINDINGS:BOOL=OFF \
      ..

cmake --build . --config Release

if [[ ("${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "") ]]; then
  ctest --output-on-failure  -C Release 
fi

cmake --build . --config Release --target install

# Generate and copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    multisheller ${RECIPE_DIR}/${CHANGE}.msh --output ./${CHANGE}
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
    cp "${CHANGE}.bash" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.bash"
    cp "${CHANGE}.xsh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.xsh"
    cp "${CHANGE}.zsh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.zsh"
    cp "${CHANGE}.ps1" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.ps1"
done
