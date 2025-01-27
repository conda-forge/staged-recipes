#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

update_antmicro_submodule() {
  local commit=$1
  local module=$2

  git clone https://github.com/antmicro/${module}.git
  pushd ${module}
    git fetch origin ${commit}
    git submodule update --init --recursive
  popd
}

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
export PATH="${DOTNET_ROOT}/dotnet:${PATH}"

install_prefix="${PREFIX}/opt/${PKG_NAME}"

dotnet_version=$(dotnet --version)
framework_version=${dotnet_version%.*}

mkdir -p ${SRC_DIR}/src/Infrastructure/
mv renode-infrastructure/* ${SRC_DIR}/src/Infrastructure/ && rm -rf renode-infrastructure

mkdir -p ${SRC_DIR}/lib
pushd ${SRC_DIR}/lib
  git clone https://github.com/renode/renode-resources.git
  pushd renode-resources && git submodule update --init --recursive && popd
  mv renode-resources resources

  update_antmicro_submodule b1d3d03d602581fc2bed6db586b5e5c3388456c7 AntShell
  update_antmicro_submodule e7bfa5873f2300e6e87c185f466e227762dbf4b2 BigGustave
  update_antmicro_submodule b0c2a820f28a7bdedb85575bfca6447c9e7fa955 CxxDemangler
  update_antmicro_submodule de4e4f6ffab555771285cb810f17f61cfd38ef39 ELFsharp
  rm -rf ELFSharp && mv ELFsharp ELFSharp
  update_antmicro_submodule e379e8ae696676afffed2f33dd8083855af00f2f FdtSharp
  update_antmicro_submodule 33e5ab24eaaab488e9a94f1a40d5d6ae2f7f02f1 InpliTftpServer
  update_antmicro_submodule c6514e99f2c35afec083b9f4a7eec3408c0081d1 Migrant
  update_antmicro_submodule 2fe74fd257f6d6f86076c100952178f347098b3d Packet.Net
  update_antmicro_submodule 33d24f1307d267c34b7f1439bc159a8825c5aa3d bc-csharp
  update_antmicro_submodule bde21d04fbfc540989b7a0ac13a54eae8b756994 cctask
  update_antmicro_submodule e8c2051dec56c5ccd3a4927b07a5740f34eed8c8 options-parser
  update_antmicro_submodule 71af57ef4fec29e416f48160b8918057a58548a9 termsharp
popd

find lib src tests -name "*.csproj" -exec sed -i -E \
  -e "s/([>;])net6.0([<;])/\1net${framework_version}\2/" \
  -e "s|^((\s+)<PropertyGroup>)|\1\n\2\2<NoWarn>CS0168;CS0219;CS8981;SYSLIB0050;SYSLIB0051</NoWarn>|" \
  -e 's|^(\s+)<(Package)?Reference\s+Include="Mono.Posix".*\n||g' \
  {} \;
find . -type d -name "obj" -exec rm -rf {} +
find . -type d -name "bin" -exec rm -rf {} +
sed -i -E 's/(ReleaseHeadless\|Any .+ = )Debug/\1Release/' Renode_NET.sln

export CC=${CC}
export CFLAGS="${CFLAGS} -fPIC"

if [[ "${target_platform}" == linux-* ]] || [[ "${target_platform}" == osx-* ]]; then
  _os_name=${target_platform%-*}

  ./build.sh --net --no-gui --force-net-framework-version ${framework_version}
else
  _os_name=windows
  ./build.sh --net --no-gui --force-net-framework-version ${framework_version}
fi


mkdir -p $PREFIX/libexec/${PKG_NAME}
cp -r output/bin/Release/net${framework_version}/* $PREFIX/libexec/${PKG_NAME}/

mkdir -p $PREFIX/opt/${PKG_NAME}/scripts
mkdir -p $PREFIX/opt/${PKG_NAME}/platforms
mkdir -p $PREFIX/opt/${PKG_NAME}/tests
mkdir -p $PREFIX/opt/${PKG_NAME}/tools
mkdir -p $PREFIX/opt/${PKG_NAME}/licenses

cp .renode-root $PREFIX/opt/${PKG_NAME}/
cp -r scripts/* $PREFIX/opt/${PKG_NAME}/scripts/
cp -r platforms/* $PREFIX/opt/${PKG_NAME}/platforms/
cp -r tests/* $PREFIX/opt/${PKG_NAME}/tests/
cp -r tools/metrics_analyzer $PREFIX/opt/${PKG_NAME}/tools
cp -r tools/execution_tracer $PREFIX/opt/${PKG_NAME}/tools
cp -r tools/gdb_compare $PREFIX/opt/${PKG_NAME}/tools
cp -r tools/sel4_extensions $PREFIX/opt/${PKG_NAME}/tools

cp lib/resources/styles/robot.css $PREFIX/opt/${PKG_NAME}/tests

tools/packaging/common_copy_licenses.sh $PREFIX/opt/${PKG_NAME}/licenses $_os_name
cp -r $PREFIX/opt/${PKG_NAME}/licenses license-files

sed -i.bak "s#os\.path\.join(this_path, '\.\./lib/resources/styles/robot\.css')#os.path.join(this_path,'robot.css')#g" $PREFIX/opt/${PKG_NAME}/tests/robot_tests_provider.py
rm $PREFIX/opt/${PKG_NAME}/tests/robot_tests_provider.py.bak

mkdir -p $PREFIX/bin/
cat > $PREFIX/bin/renode <<"EOF"
#!/bin/sh
exec "${DOTNET_ROOT}"/dotnet exec "${CONDA_PREFIX}"/libexec/renode-cli/Renode.dll "$@"
EOF
chmod +x ${PREFIX}/bin/renode

cat > $PREFIX/bin/renode.cmd <<"EOF"
call %DOTNET_ROOT%\dotnet exec %CONDA_PREFIX%\libexec\libexec\renode-cli\Renode.dll %*
EOF
chmod +x ${PREFIX}/bin/renode

cat > $PREFIX/bin/renode-test <<"EOF"
#!/usr/bin/env bash

STTY_CONFIG=`stty -g 2>/dev/null`
python3 "${CONDA_PREFIX}"/opt/"${PKG_NAME}"/tests/run_tests.py --robot-framework-remote-server-full-directory "${CONDA_PREFIX}"/libexec/"${PKG_NAME}" "$@"
RESULT_CODE=$?
if [ -n "${STTY_CONFIG:-}" ]
then
    stty "$STTY_CONFIG"
fi
exit $RESULT_CODE
EOF
chmod +x ${PREFIX}/bin/renode-test
