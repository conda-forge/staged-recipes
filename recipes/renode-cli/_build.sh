#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

main() {
  export PATH="${DOTNET_ROOT}/dotnet:${PATH}"

  dotnet_version=$(dotnet --version)
  framework_version=${dotnet_version%.*}

  # Patch the project files to use the correct .NET version
  find lib src tests -name "*.csproj" -exec sed -i -E \
    -e "s/([>;])net6.0([<;])/\1net${framework_version}\2/" \
    {} \;
  #DEBUG:  -e "s|^((\s+)<PropertyGroup>)|\1\n\2\2<NoWarn>CS0168;CS0219;CS8981;SYSLIB0050;SYSLIB0051</NoWarn>|" \
  #Does this prevents the compile/install of Mono related .dll?  -e 's|^(\s+)<(Package)?Reference\s+Include="Mono.Posix".*\n||g' \

  find . -type d -name "obj" -exec rm -rf {} +
  find . -type d -name "bin" -exec rm -rf {} +

  # Typo in release, already fixed in master
  # This is solved in upstream master - Also, patching with leading tabs seems to fail with rattler
  sed -i -E 's/(ReleaseHeadless\|Any .+ = )Debug/\1Release/' Renode_NET.sln

  # Prevent CMake build since we provide the binaries
  mkdir -p ${SRC_DIR}/src/Infrastructure/src/Emulator/Cores/bin/Release/lib
  ln -s ${PREFIX}/lib/renode-cores/* ${SRC_DIR}/src/Infrastructure/src/Emulator/Cores/bin/Release/lib

  # Remove the C cores that are not built in this recipe
  rm -f ${SRC_DIR}/src/Infrastructure/src/Emulator/Cores/translate*.cproj

  chmod +x tools/{building,packaging}/*.sh
  ${RECIPE_DIR}/helpers/renode_build_with_dotnet.sh ${framework_version}

  # Install procedure
  mkdir -p ${PREFIX}/bin
  mkdir -p ${PREFIX}/libexec/${PKG_NAME}
  mkdir -p ${PREFIX}/share/${PKG_NAME}/{scripts,platforms,tests}

  cp -r output/bin/Release/net${framework_version}/* ${PREFIX}/libexec/${PKG_NAME}/
  cp -r scripts/*                                    ${PREFIX}/share/${PKG_NAME}/scripts/
  cp -r platforms/*                                  ${PREFIX}/share/${PKG_NAME}/platforms/

  mkdir -p license-files
  if [[ "${target_platform}" == "osx-*" ]]; then
    tools/packaging/common_copy_licenses.sh license-files macos
  else
    tools/packaging/common_copy_licenses.sh license-files linux
  fi

  mkdir -p ${PREFIX}/bin/
  cat > ${PREFIX}/bin/renode <<"EOF"
#!/bin/sh
exec "${DOTNET_ROOT}"/dotnet exec "${CONDA_PREFIX}"/libexec/renode-cli/Renode.dll "$@"
EOF
  chmod +x ${PREFIX}/bin/renode

  # Do we need to install the tests?
  install_tests "${SRC_DIR}/test-bundle" "$PKG_NAME" "$PREFIX"
}

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

# Refactoring into separate companion packages
# mkdir -p ${PREFIX}/opt/${PKG_NAME}/tools
# cp -r tools/metrics_analyzer ${PREFIX}/opt/${PKG_NAME}/tools
# cp -r tools/execution_tracer ${PREFIX}/opt/${PKG_NAME}/tools
# cp -r tools/gdb_compare ${PREFIX}/opt/${PKG_NAME}/tools
# cp -r tools/sel4_extensions ${PREFIX}/opt/${PKG_NAME}/tools
