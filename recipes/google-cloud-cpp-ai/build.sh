#!/bin/bash

set -euo pipefail

export OPENSSL_ROOT_DIR=$PREFIX

if [[ "${target_platform}" == osx-* ]]; then
  # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
  CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# This list represents some of the larger features in `google-cloud-cpp`.
# Moving them to their own feedstock splits the build time across feedstocks.
# The features happen to be AI and ML related, which provides a good nemonic
# for the feedstock.  They are not, however, all the AI based features in
# `google-cloud-cpp`.
feature_list=(
  aiplatform
  automl
  discoveryengine
  dialogflow_es
  dialogflow_cx
  dlp
  speech
  texttospeech
  timeseriesinsights
  translate
  videointelligence
  vision
)
for feature in "${feature_list[@]}"; do
  echo "$(date -u '+%Y-%m-%dT%H:%M:%SZ'): Building ${feature}"
  cmake ${CMAKE_ARGS} \
      -GNinja -S . -B .build/${feature} \
      -DGOOGLE_CLOUD_CPP_ENABLE=${feature} \
      -DGOOGLE_CLOUD_CPP_USE_INSTALLED_COMMON=ON \
      -DBUILD_TESTING=OFF \
      -DBUILD_SHARED_LIBS=ON \
      -DOPENSSL_ROOT_DIR=$PREFIX \
      -DCMAKE_BUILD_TYPE=release \
      -DCMAKE_CXX_STANDARD=17 \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DProtobuf_PROTOC_EXECUTABLE=$BUILD_PREFIX/bin/protoc \
      -DGOOGLE_CLOUD_CPP_GRPC_PLUGIN_EXECUTABLE=$BUILD_PREFIX/bin/grpc_cpp_plugin \
      -DGOOGLE_CLOUD_CPP_ENABLE_WERROR=OFF
  cmake --build .build/${feature}
  echo "$(date -u '+%Y-%m-%dT%H:%M:%SZ'): DONE - Building ${feature}"
done
