@echo on

mkdir build
cd build

cmake ^
  -LAH ^
  %CMAKE_ARGS% ^
  ..

cmake --build . --clean-first

ctest -C Release

mkdir %PREFIX%/include/otf
mkdir %PREFIX%/include/otf/uk_co_real_logic_sbe_ir_generated

copy %SRC_DIR%/sbe-tool/src/main/cpp/otf/*.h %PREFIX%/include/otf
copy %SRC_DIR%/sbe-tool/src/main/cpp/uk_co_real_logic_sbe_ir_generated/*.h %PREFIX%/include/otf/uk_co_real_logic_sbe_ir_generated
