#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export PATH="${DOTNET_ROOT}/dotnet:${PATH}"

dotnet_version=$(dotnet --version)
framework_version=${dotnet_version%.*}

# Patch project files
find lib src tests -name "*.csproj" -exec sed -i -E "s/([>;])net6.0([<;])/\1net${framework_version}\2/g" {} \;

# Remove obj and bin directories
find . -name "obj" -o -name "bin" -type d -exec rm -rf {} +

# Fix typo in Renode_NET.sln
if [[ "${PKG_VERSION}" == "1.15.3" ]]; then
    sed -i -E 's/ReleaseHeadless\|Any (.+) = Debug/ReleaseHeadless\|Any \1 = Release/' Renode_NET.sln
    sed -i -E 's/GetBytes\(registers.Read\(offset\)\);/GetBytes((ushort)registers.Read(offset));/' src/Infrastructure/src/Emulator/Peripherals/Peripherals/Sensors/PAC1934.cs
    sed -i -E 's/"System.Drawing.Common" Version="5.0.2"/"System.Drawing.Common" Version="5.0.3"/' lib/termsharp/TermSharp_NET.csproj lib/termsharp/xwt/Xwt.Gtk/Xwt.Gtk3_NET.csproj
else
    echo "Remove these patches from the script after 1.15.3"
    exit 1
fi

# Renode computes its version based upon `git rev-parse --short=8 HEAD`
sed -i -E "s/\`git rev-parse --short=8 HEAD\`/0/" ${SRC_DIR}/tools/building/createAssemblyInfo.sh

# Prepare for build
mkdir -p "${SRC_DIR}/src/Infrastructure/src/Emulator/Cores/bin/Release/lib"
ln -sf ${PREFIX}/lib/renode-cores/* "${SRC_DIR}/src/Infrastructure/src/Emulator/Cores/bin/Release/lib"

rm -f "${SRC_DIR}/src/Infrastructure/src/Emulator/Cores/translate*.cproj"

# Build with dotnet
mkdir -p "${SRC_DIR}/output/bin/Release/net${framework_version}"
cp "${SRC_DIR}/src/Infrastructure/src/Emulator/Cores/${target_platform%%-*}-properties_NET.csproj" "${SRC_DIR}/output/properties.csproj"

dotnet build \
  -p:GUI_DISABLED=true \
  -p:Configuration=ReleaseHeadless \
  -p:GenerateFullPaths=true \
  -p:Platform="Any CPU" \
  ${SRC_DIR}/Renode_NET.sln
echo -n "dotnet" > "${SRC_DIR}/output/bin/Release/build_type"

# Copy LLVM library (simplified logic)
LLVM_LIB="libllvm-disas"
cp "lib/resources/llvm/$LLVM_LIB$SHLIB_EXT" "${SRC_DIR}/output/bin/Release/libllvm-disas$SHLIB_EXT"

# Install procedure
mkdir -p ${PREFIX}/bin ${PREFIX}/libexec/${PKG_NAME} ${PREFIX}/share/${PKG_NAME}/{scripts,platforms,tools/sel4_extensions} ${SRC_DIR}/license-files

cp -r ${SRC_DIR}/output/bin/Release/net${framework_version}/* ${PREFIX}/libexec/${PKG_NAME}/
cp -r ${SRC_DIR}/scripts/* "${PREFIX}/share/${PKG_NAME}/scripts/"
cp -r ${SRC_DIR}/platforms/* "${PREFIX}/share/${PKG_NAME}/platforms/"
cp -r ${SRC_DIR}/tools/sel4_extensions "${PREFIX}/share/${PKG_NAME}/tools/"

# Remove Mono dynamic library
find ${PREFIX}/libexec/${PKG_NAME} -name "libMonoPosixHelper.so" -exec rm -f {} +

dotnet-project-licenses --input "$SRC_DIR/src/Renode/Renode_NET.csproj" -d "$SRC_DIR/license-files"

# Create renode script (using heredoc)
cat > "${PREFIX}/bin/renode" <<EOF
#!/bin/sh
exec "\${DOTNET_ROOT}"/dotnet exec "\${CONDA_PREFIX}"/libexec/renode-cli/Renode.dll "\$@"
EOF
chmod +x "${PREFIX}/bin/renode"

# Install tests for post-install testing
TEST_PREFIX="${SRC_DIR}/test-bundle"

mkdir -p "${TEST_PREFIX}/bin"
mkdir -p "${TEST_PREFIX}/share/${PKG_NAME}/tests"
cp -r tests/* "${TEST_PREFIX}/share/${PKG_NAME}/tests/"
cp lib/resources/styles/robot.css "${TEST_PREFIX}/share/${PKG_NAME}/tests"

sed -i "s#os\.path\.join(this_path, '\.\./lib/resources/styles/robot\.css')#os.path.join(this_path,'robot.css')#g" "${TEST_PREFIX}/share/${PKG_NAME}/tests/robot_tests_provider.py"

cat > "${TEST_PREFIX}/bin/renode-test" <<EOF
#!/usr/bin/env bash
stty_config=\$(stty -g 2>/dev/null)
python3 "\${LOCAL_TEST_PREFIX:-\${CONDA_PREFIX}}"/share/"${PKG_NAME}"/tests/run_tests.py --robot-framework-remote-server-full-directory "${CONDA_PREFIX}"/libexec/renode-cli "\$@"
result_code=\$?
if [[ -n "\${stty_config+_}" ]]; then stty "\$stty_config"; fi
exit \$result_code
EOF
chmod +x "${TEST_PREFIX}/bin/renode-test"

exit 0
