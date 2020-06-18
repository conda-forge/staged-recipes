#!/bin/bash

curl -fSsLO https://files.pythonhosted.org/packages/51/cd/a0c1f9e4582ea64dddf76c1b808b318d01e3b858a51c715bffab1016ecc7/tensorboard_plugin_wit-${PKG_VERSION}.post3-py3-none-any.whl
pip install --no-deps tensorboard_plugin_wit-${PKG_VERSION}*py3*.whl && exit 0

BAZEL_VERSION=0.29.1
curl -fSsLO https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh
bash bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh --prefix="${PWD}/bazel_local"
export PATH=${PWD}/bazel_local/bin:${PATH}

sed -i "s|pushd release|cd release|g" tensorboard_plugin_wit/pip_package/build_pip_package.sh
sed -i "s|pip install|#pip install|g" tensorboard_plugin_wit/pip_package/build_pip_package.sh

bazel run --verbose_failures --python_path=${PREFIX}/bin/python  --define=EXECUTOR=remote tensorboard_plugin_wit/pip_package:build_pip_package

pip install --no-deps /tmp/wit-pip/release/dist/tensorboard_plugin_wit-${PKG_VERSION}-py3*.whl
