@echo on

REM SetLocal EnableDelayedExpansion

if not "%cuda_compiler_version%"=="None" {
    for /F "tokens=1,2 delims=." %%a in ("%cuda_compiler_version%") do (
        set a=%%a
        set b=%%b
    )
    set padded=00%b%
    set padded=%padded:~-2%
    set num_ver=%a%%padded%
    echo "%num_ver%"

REM    set ARCHES=50 52 53 60 61 62 70 72 75 80 86 87
        
}

REM set -o errexit
REM set -o nounset
REM set -o xtrace
REM 
REM # function to facilitate version comparison; cf. https://stackoverflow.com/a/37939589
REM version2int () { echo "$@" | awk -F. '{ printf("%d%02d\n", $1, $2); }'; }
REM 
REM declare -a CUDA_CONFIG_ARGS
REM if [ "${cuda_compiler_version}" != "None" ]; then
REM     cuda_compiler_version_int=$(version2int "$cuda_compiler_version") 
REM 
REM     ARCHES=(50 52 53 60 61 62 70 72 75 80 86 87)
REM     if [ $cuda_compiler_version_int -le $(version2int "11.8") ]; then
REM         ARCHES=(35 37 "${ARCHES[@]}")
REM     fi
REM     if [ $cuda_compiler_version_int -ge $(version2int "11.8") ]; then
REM         ARCHES=("${ARCHES[@]}" 89 90)
REM     fi
REM     if [ $cuda_compiler_version_int -ge $(version2int "12.0") ]; then
REM         ARCHES=("${ARCHES[@]}" 90a)
REM     fi
REM 
REM     LATEST_ARCH="${ARCHES[-1]}"
REM     unset "ARCHES[${#ARCHES[@]}-1]"
REM 
REM     for arch in "${ARCHES[@]}"; do
REM         CMAKE_CUDA_ARCHS="${CMAKE_CUDA_ARCHS+${CMAKE_CUDA_ARCHS};}${arch}-real"
REM     done
REM 
REM     CMAKE_CUDA_ARCHS="${CMAKE_CUDA_ARCHS+${CMAKE_CUDA_ARCHS};}${LATEST_ARCH}"
REM 
REM     CUDA_CONFIG_ARGS+=(
REM         -DCMAKE_CUDA_ARCHITECTURES="${CMAKE_CUDA_ARCHS}"
REM     )
REM fi
REM 
REM BUILD_DIR="$SRC_DIR/build"
REM BIN_DIR="$PREFIX/bin"
REM 
REM mkdir -p "$BUILD_DIR"
REM cd "$BUILD_DIR"
REM 
REM cmake ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release ${CUDA_CONFIG_ARGS+"${CUDA_CONFIG_ARGS[@]}"} "$SRC_DIR"
REM make VERBOSE=1
REM 
REM install --mode 0755 --directory "$BIN_DIR"
REM install --mode 0755 $SRC_DIR/build/segalign{,_repeat_masker} "$BIN_DIR"
REM install --mode 0755 $SRC_DIR/scripts/run_segalign{,_repeat_masker} "$BIN_DIR"
