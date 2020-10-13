#!/bin/bash
# Originally forked from https://github.com/AnacondaRecipes/cudatoolkit-feedstock
# Distributed under the BSD-2-Clause license
# Copyright (c) 2017, Continuum Analytics, Inc. All rights reserved.
#
# post install EULA message; `pre-link.sh` does not show message and shows warning
echo "By downloading and using the CUDA Toolkit conda packages, you accept the terms and conditions of the CUDA End User License Agreement (EULA): https://docs.nvidia.com/cuda/eula/index.html" >> $PREFIX/.messages.txt
