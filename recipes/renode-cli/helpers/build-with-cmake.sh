HOST_ARCH="i386"
CMAKE_COMMON=""
CORES_PATH="$ROOT_PATH/src/Infrastructure/src/Emulator/Cores"
OUT_BIN_DIR="$(get_path "output/bin/${CONFIGURATION}")"
BUILD_TYPE_FILE=$(get_path "${OUT_BIN_DIR}/build_type")

# clean instead of building
if $CLEAN
then
    for project_dir in $(find "$(get_path "${ROOT_PATH}/src")" -iname '*.csproj' -exec dirname '{}' \;)
    do
      for dir in {bin,obj}/{Debug,Release}
      do
        output_dir="$(get_path "${project_dir}/${dir}")"
        if [[ -d "${output_dir}" ]]
        then
          echo "Removing: ${output_dir}"
          rm -rf "${output_dir}"
        fi
      done
    done

    # Manually clean the main output directory as it's location is non-standard
    main_output_dir="$(get_path "${OUTPUT_DIRECTORY}/bin")"
    if [[ -d "${main_output_dir}" ]]
    then
      echo "Removing: ${main_output_dir}"
      rm -rf "${main_output_dir}"
    fi
    exit 0
fi

# Check if a full rebuild is needed
if [[ -f "$BUILD_TYPE_FILE" ]]
then
  if [[ "$(cat "$BUILD_TYPE_FILE")" != "$BUILD_TYPE" ]]
  then
    echo "Attempted to build Renode in a different configuration than the previous build"
    echo "Please run '$0 -c' to clean the previous build before continuing"
    exit 1
  fi
fi

# Paths for tlib
CORES_BUILD_PATH="$CORES_PATH/obj/$CONFIGURATION"
CORES_BIN_PATH="$CORES_PATH/bin/$CONFIGURATION"

# Cmake generator, handled in their own variable since the names contain spaces
if $ON_WINDOWS
then
    CMAKE_GEN="-GMinGW Makefiles"
else
    CMAKE_GEN="-GUnix Makefiles"
fi

# Macos architecture flags, to make rosetta work properly
if $ON_OSX
then
  CMAKE_COMMON+=" -DCMAKE_OSX_ARCHITECTURES=x86_64"
  if [ $HOST_ARCH == "aarch64" ]; then
    CMAKE_COMMON+=" -DCMAKE_OSX_ARCHITECTURES=arm64"
  fi
fi

# This list contains all cores that will be built.
# If you are adding a new core or endianness add it here to have the correct tlib built
CORES=(arm.le arm.be arm64.le arm-m.le arm-m.be ppc.le ppc.be ppc64.le ppc64.be i386.le x86_64.le riscv.le riscv64.le sparc.le sparc.be xtensa.le)

# build tlib
for core_config in "${CORES[@]}"
do
    CORE="$(echo $core_config | cut -d '.' -f 1)"
    ENDIAN="$(echo $core_config | cut -d '.' -f 2)"
    BITS=32
    # Check if core is 64-bit
    if [[ $CORE =~ "64" ]]; then
      BITS=64
    fi
    # Core specific flags to cmake
    CMAKE_CONF_FLAGS="-DTARGET_ARCH=$CORE -DTARGET_WORD_SIZE=$BITS -DCMAKE_BUILD_TYPE=$CONFIGURATION"
    CORE_DIR=$CORES_BUILD_PATH/$CORE/$ENDIAN
    mkdir -p $CORE_DIR
    pushd "$CORE_DIR" > /dev/null
    if [[ $ENDIAN == "be" ]]; then
        CMAKE_CONF_FLAGS+=" -DTARGET_BIG_ENDIAN=1"
    fi
    cmake "$CMAKE_GEN" $CMAKE_COMMON $CMAKE_CONF_FLAGS -DHOST_ARCH=$HOST_ARCH $CORES_PATH
    cmake --build . -j$(nproc)
    CORE_BIN_DIR=$CORES_BIN_PATH/lib
    mkdir -p $CORE_BIN_DIR
    if $ON_OSX; then
        # macos `cp` does not have the -u flag
        cp -v tlib/*.so $CORE_BIN_DIR/
    else
        cp -u -v tlib/*.so $CORE_BIN_DIR/
    fi
    # copy compile_commands.json to tlib directory
    if [[ "$TLIB_EXPORT_COMPILE_COMMANDS" = true ]]; then
       command cp -v -f $CORE_DIR/compile_commands.json $CORES_PATH/tlib/
    fi
    popd > /dev/null
done

if $TLIB_ONLY
then
    exit 0
fi
