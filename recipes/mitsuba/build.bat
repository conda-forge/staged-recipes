@echo on

set "CMAKE_BUILD_PARALLEL_LEVEL=%CPU_COUNT%"
if %CPU_COUNT% GTR 8 set "CMAKE_BUILD_PARALLEL_LEVEL=8"
set "CMAKE_GENERATOR=Ninja"
set "CMAKE_GENERATOR_PLATFORM="
set "CMAKE_GENERATOR_TOOLSET="

rem Keep the pristine Dr.Jit headers ahead of the packaged headers while
rem conda-forge carries its temporary raw-pointer scatter patch. Remove this
rem after https://github.com/mitsuba-renderer/drjit/pull/518 is released and
rem the corresponding conda-forge patch is retired.
set "CL=/I%SRC_DIR%\ext\drjit\include %CL%"

set "MI_VARIANTS=scalar_rgb,scalar_spectral,scalar_spectral_polarized,llvm_ad_rgb,llvm_ad_mono,llvm_ad_mono_polarized,llvm_ad_spectral,llvm_ad_spectral_polarized"
set "CMAKE_ARGS=%CMAKE_ARGS% -DMI_DEFAULT_VARIANTS=%MI_VARIANTS%"

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
