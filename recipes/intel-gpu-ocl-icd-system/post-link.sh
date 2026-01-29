#!/usr/bin/bash

# Copyright 2020-2024 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

systemwide_vendors=/etc/OpenCL/vendors
env_vendors=${PREFIX}/etc/OpenCL/vendors
env_icd_fn=$env_vendors/intel-ocl-gpu.icd

if [[ -d $systemwide_vendors ]]
then
    systemwide_icd_fn=$(grep -rl "libigdrcl" ${systemwide_vendors})
    if [[ -f $systemwide_icd_fn ]]
    then
        ln -s $systemwide_icd_fn $env_icd_fn
        echo "Symbolic link was successfully created. OpenCL GPU device should be discoverable by OpenCL loader.\n" >> ${PREFIX}/.messages.txt
    else
        echo "No ICD file for Intel(R) GPU device was found in '${systemwise_vendors}'.\n" >> ${PREFIX}/.messages.txt
        echo "Creating default symbolic link.\n" >> ${PREFIX}/.messages.txt
        ln -s ${systemwide_vendors}/intel.icd $env_icd_fn
    fi
else
    echo "Folder '${systemwide_vendors}' does not exist. \n" >> $PREFIX/.messages.txt
    echo "Creating default symbolic link. \n" >> ${PREFIX}/.messages.txt
    ln -s ${systemwide_vendors}/intel.icd $env_icd_fn
fi
