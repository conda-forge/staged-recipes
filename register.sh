set -ex
SCRIPT=$(readlink -f $0)
dirname=$(dirname ${SCRIPT})
conda smithy init ${dirname}/recipes/$1

pushd "$1-feedstock"
cat > conda-forge.yml <<EOF
github:
  user_or_org: qtforge
channels:
  targets:
  -
    - qtforge
build_platform:
  linux_aarch64: linux_64
  linux_ppc64le: linux_64
  osx_arm64: osx_64
conda_build:
  pkg_format: '2'
conda_forge_output_validation: true
github:
  branch_name: main
  tooling_branch_name: main
os_version:
  linux_64: cos7
provider:
  linux_aarch64: azure
  linux_ppc64le: azure
test_on_native_only: true
EOF

git add conda-forge.yml
git commit -m "Add qtforge information"


conda smithy rerender --commit auto
conda smithy register-github --organization qtforge .
git push --set-upstream upstream main

# I can't get this last part to register on Azure automatically
# I somewhat give up here
#     --user qtforge \
# AZURE_ORG_OR_USER=markharfouche0439
# AZURE_ORG_OR_USER=qtforge conda smithy register-ci \
#     --organization qtforge \
#     --without-travis \
#     --without-circle \
#     --without-appveyor \
#     --without-drone \
#     --without-webservice


popd
