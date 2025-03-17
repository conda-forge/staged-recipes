#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Consolidated script logic
main() {
    export PATH="${DOTNET_ROOT}/dotnet:${PATH}"

    dotnet_version=$(dotnet --version)
    framework_version=${dotnet_version%.*}

    # Patch project files (combined find and sed)
    find lib src tests -name "*.csproj" -exec sed -i -E "s/([>;])net6.0([<;])/\1net${framework_version}\2/g" {} \;

    # Remove obj and bin directories (combined find)
    find . -name "obj" -o -name "bin" -type d -exec rm -rf {} +

    # Fix typo in Renode_NET.sln
    sed -i -E 's/(ReleaseHeadless\|Any .+ = )Debug/\1Release/' Renode_NET.sln

    # Prepare for build (using more robust path)
    mkdir -p "${SRC_DIR}/src/Infrastructure/src/Emulator/Cores/bin/Release/lib"
    ln -sf ${PREFIX}/lib/renode-cores/* "${SRC_DIR}/src/Infrastructure/src/Emulator/Cores/bin/Release/lib"

    rm -f "${SRC_DIR}/src/Infrastructure/src/Emulator/Cores/translate*.cproj"

    # Build with dotnet (combined commands and simplified logic)
    mkdir -p "${SRC_DIR}/output/bin/Release/net${framework_version}"
    cp "${SRC_DIR}/src/Infrastructure/src/Emulator/Cores/${target_platform%%-*}-properties.csproj" "${SRC_DIR}/output/properties.csproj"

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

    # Install procedure (combined mkdir)
    mkdir -p ${PREFIX}/bin ${PREFIX}/libexec/${PKG_NAME} ${PREFIX}/share/${PKG_NAME}/{scripts,platforms,tests}

    cp -r ${SRC_DIR}/output/bin/Release/net${framework_version}/* ${PREFIX}/libexec/${PKG_NAME}/
    cp -r ${SRC_DIR}/scripts/* "${PREFIX}/share/${PKG_NAME}/scripts/"
    cp -r ${SRC_DIR}/platforms/* "${PREFIX}/share/${PKG_NAME}/platforms/"

    # Copy licenses (simplified conditional)
    mkdir -p ${SRC_DIR}/license-files
    if [[ "${target_platform}" == "osx-*" ]]; then
        tools/packaging/common_copy_licenses.sh ${SRC_DIR}/license-files macos
    else
        tools/packaging/common_copy_licenses.sh ${SRC_DIR}/license-files linux
    fi

    # Create renode script (using heredoc)
    cat > "${PREFIX}/bin/renode" <<EOF
#!/bin/sh
exec "\${DOTNET_ROOT}"/dotnet exec "\${CONDA_PREFIX}"/libexec/renode-cli/Renode.dll "\$@"
EOF
    chmod +x "${PREFIX}/bin/renode"

    # Install tests
    install_tests "${SRC_DIR}/test-bundle" "$PKG_NAME" "$PREFIX"
}

# Function to install tests (defined after main logic)
install_tests() {
    local test_prefix="$1"
    local pkg_name="$2"
    local conda_prefix="$3"

    mkdir -p "${test_prefix}/bin"
    mkdir -p "${test_prefix}/share/${pkg_name}/tests"
    cp -r tests/* "${test_prefix}/share/${pkg_name}/tests/"
    cp lib/resources/styles/robot.css "${test_prefix}/share/${pkg_name}/tests"

    sed -i "s#os\.path\.join(this_path, '\.\./lib/resources/styles/robot\.css')#os.path.join(this_path,'robot.css')#g" "${test_prefix}/share/${pkg_name}/tests/robot_tests_provider.py"

    cat > "${test_prefix}/bin/renode-test" <<EOF
#!/usr/bin/env bash
stty_config=\$(stty -g 2>/dev/null)
python3 "\${LOCAL_TEST_PREFIX:-\${conda_prefix}}"/share/"${pkg_name}"/tests/run_tests.py --robot-framework-remote-server-full-directory "${conda_prefix}"/libexec/renode-cli "\$@"
result_code=\$?
if [[ -n "\${stty_config+_}" ]]; then stty "\$stty_config"; fi
exit \$result_code
EOF
    chmod +x "${test_prefix}/bin/renode-test"
}

main "$@"

exit 0
