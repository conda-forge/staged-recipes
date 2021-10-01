#!/bin/bash
# *****************************************************************
# (C) Copyright IBM Corp. 2020, 2021. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# *****************************************************************
set -vex

#Clean up old bazel cache to avoid problems building TF
bazel clean --expunge
bazel shutdown

sh ${SRC_DIR}/oss_scripts/run_build.sh

# install using pip from the whl file
pip install --no-deps $SRC_DIR/tensorflow_text*p${CONDA_PY}*.whl

bazel clean --expunge
bazel shutdown
