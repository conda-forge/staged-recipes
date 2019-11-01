#!/bin/bash
ls
cmake . -DKIM_API_MODEL_DRIVER_INSTALL_PREFIX=${PREFIX}/lib64/kim-api/model-drivers -DKIM_API_PORTABLE_MODEL_INSTALL_PREFIX=${PREFIX}/lib64/kim-api/portable-models -DKIM_API_SIMULATOR_MODEL_INSTALL_PREFIX=${PREFIX}/lib64/kim-api/simulator-models
make
